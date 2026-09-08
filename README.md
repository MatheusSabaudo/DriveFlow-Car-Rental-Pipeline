# DriveFlow — Car Rental Data Platform

**DriveFlow is an end-to-end data pipeline for a fictional car-rental company, built to learn the core AWS data-engineering stack hands-on — on real AWS, not emulators.**

The project simulates a rental business (a fleet of vehicles, rentals across branches, customers, and odometer telemetry), then runs that data through the full lifecycle a real data team owns: **generate → ingest → clean → model into KPIs → load into a warehouse → visualize**. Each stage is deliberately built on a different AWS service so that, by the end, I've used every important building block of an AWS data platform for a real reason — not from a tutorial.

It's a personal learning project. The data is fake (Faker-generated); the AWS services, the pipeline, and the engineering practices are real.

<p align="left">
  <img alt="Terraform" src="https://img.shields.io/badge/IaC-Terraform%20%E2%89%A51.10-7B42BC">
  <img alt="AWS" src="https://img.shields.io/badge/Cloud-AWS%20eu--central--1-FF9900">
  <img alt="Spark" src="https://img.shields.io/badge/Compute-EMR%20Serverless%20%2F%20Spark-E25A1C">
  <img alt="Orchestration" src="https://img.shields.io/badge/Orchestration-MWAA%20%2F%20Airflow-CC2264">
  <img alt="Budget" src="https://img.shields.io/badge/Monthly%20cost-%3C%20%2450-2E7D32">
</p>

---

## The goal: learn AWS data engineering, service by service

I'm using this project to get real, hands-on experience with the services that make up a modern AWS data platform. Rather than read about each one in isolation, I'm wiring them together into a single pipeline so I understand *how they connect* and *when to reach for which*.

| AWS service | Role in DriveFlow | What I'm learning |
|---|---|---|
| **S3** | Data lake — RAW / CLEANSED / CURATED / scripts zones | Partitioning, lifecycle, the zone/medallion pattern |
| **RDS (Postgres)** | Operational source (`ops`) + analytics target (`analytics`) | OLTP modeling, `COPY`/JDBC vs. driver loads, security groups |
| **AWS Glue** | Python-shell jobs (generate, extract, load) — no cluster, no NAT | Serverless job types, DPU cost, Glue Data Catalog |
| **Amazon EMR (Serverless)** | Spark ETL for the `clean` + `kpi` jobs | Cluster sizing, spot, YARN, per-second billing |
| **Amazon MWAA / Airflow** | Primary orchestrator of the pipeline | DAGs, operators, datasets, backfills — and why not to leave it running |
| **Redshift Serverless** | Columnar MPP warehouse option | Distribution/sort keys, `COPY FROM S3`, MPP vs. row store |
| **Athena + Apache Iceberg** | Open-lakehouse query option | MERGE, time-travel, schema evolution, query-in-place |
| **Lake Formation** | Governance over the Glue Catalog + S3 zones | TBAC/LF-Tags, data cell filters, the IAM-vs-LF layering |
| **IAM** | Least-privilege roles for Glue / EMR / MWAA | Scoping permissions to exactly what each job needs |
| **AWS Budgets + SNS** | $50 budget with tiered alerts | Cost monitoring and guardrails from day one |
| **Terraform** | Provisions *everything* | Modules, remote state, provider pinning, quality gates |

---

## What the pipeline actually does

```mermaid
flowchart LR
    GEN[generate.py<br/>Faker → fleet, rentals,<br/>customers, odometer] --> RDS[(RDS Postgres<br/>ops schema)]
    RDS -->|delta extract<br/>watermark on updated_at| RAW[S3 RAW]
    RAW -->|clean.py Spark on EMR<br/>dedupe · validate · repair| CLN[S3 CLEANSED]
    CLN -->|kpi.py Spark on EMR<br/>business metrics| CUR[S3 CURATED]
    CUR --> ANL[(RDS analytics)]
    CUR --> RS[(Redshift)]
    CUR --> ICE[Iceberg + Athena]
    ANL --> BI[BI dashboard]
```

1. **Generate** — a Faker-based generator writes one "business day" of operational data into RDS: vehicles, branches, customers, rentals, and odometer readings. It intentionally injects realistic mess — duplicate rentals, open rentals with null return dates, negative/decreasing odometer values, out-of-range fuel levels, malformed emails, and future dates — so the cleaning stage has something real to fix.
2. **Extract (delta)** — a watermark on `updated_at` pulls only new/changed rows since the last run into the S3 RAW zone as partitioned Parquet. Idempotent, so reruns and backfills never duplicate.
3. **Clean** — a Spark job (on EMR) dedupes on business keys, validates emails and dates, flags open rentals, drops negative odometer readings and enforces monotonic-increasing distance per vehicle, and nulls out-of-range fuel levels — writing a small data-quality report and failing the run if error rates exceed a threshold.
4. **KPIs** — a second Spark job (on EMR) turns cleansed data into the metrics a rental business actually cares about: **fleet utilization, revenue by branch and category, average km per rental, average rental duration, open-rental rate, and revenue per vehicle** — written to the CURATED zone.
5. **Load** — curated KPIs land in the RDS `analytics` schema and, as parallel warehouse exercises, in Redshift and in an Iceberg/Athena lakehouse — all via idempotent delete-then-insert / `COPY` / `MERGE`.
6. **Visualize** — a BI layer (QuickSight) over the analytics schema: a vehicle-search view and a KPI dashboard.

The whole chain is run by **MWAA / Airflow** DAGs (`generate → extract_delta → clean → kpi → load`), chained with Airflow Datasets and triggerable with a `{"run_date": "..."}` config.

---

## One production-shaped build

DriveFlow is a single, production-shaped architecture — one job codebase and one set of Terraform modules, deployed to one `envs/prod` root:

| Concern | Choice |
|---|---|
| Orchestration | **MWAA / Airflow**, hardened |
| Spark compute | **EMR Serverless** (optional tiny EMR-on-EC2 + spot for cluster-ops practice) for `clean` / `kpi` / ML jobs |
| Light ETL / non-Spark steps | **Glue Python-shell** for `generate` / `extract_delta` / `load_warehouse` — no cluster, no NAT |
| Analytics store | **RDS `analytics` + Redshift + Iceberg/Athena** — all three, as a deliberate row / columnar-MPP / open-lakehouse comparison off the same curated Parquet |
| Governance | **Lake Formation** over the Glue Catalog + Iceberg tables |
| BI | **QuickSight** |

The expensive resources (MWAA, Redshift, EMR-on-EC2) are toggle-gated and default **off** — they only ever `deploy → test → destroy` in the same session. Step Functions is intentionally not used (MWAA is the single orchestrator).

---

## Guardrails I set for myself

- **Real AWS, never local.** No LocalStack, no Docker Spark — iterate on tiny samples against real managed services so what I learn actually transfers.
- **Ephemeral & under $50/mo.** One `terraform apply` to stand up, test, then `terraform destroy` the same session; every run ends with `terraform state list` confirmed empty. A $50 AWS Budget with alerts at $20/$35/$45 exists before anything else.
- **No accidental cost sinks.** The warehouse load runs as a Glue **Python-shell + `psycopg2`** job outside the VPC against a locked-down public RDS — deliberately avoiding a NAT gateway (~$32/mo, alone enough to break the budget). Expensive services (MWAA, Redshift, EMR-on-EC2) are toggle-gated and default **off**.
- **Idempotency by default.** Per-day partitions + overwrite-by-partition + delete-then-insert loads → safe reruns and backfills.
- **Everything in Terraform.** Reusable modules, isolated remote state (S3 + native lockfile, no DynamoDB), pinned providers, and quality gates (`fmt`, `tflint`, `tfsec`/`checkov`, `terraform-docs`).

---

## Repository layout

```
DriveFlow-Car-Rental-Pipeline/
├── infrastructure/
│   ├── bootstrap/          # one-time: creates the S3 remote-state bucket (local state)
│   └── modules/            # reusable building blocks (s3, iam_roles, rds, budget,
│                           #   glue, emr, mwaa, redshift, vpc)
├── envs/prod/              # single thin env root wiring the modules (isolated remote state)
├── jobs/                   # generate · extract_delta · clean · kpi · load_warehouse
├── include/sql/            # ddl_ops.sql · ddl_analytics.sql
├── dags/                   # Airflow DAGs (MWAA orchestrator)
└── tests/                  # pytest unit tests
```

Every module follows the same contract — `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` (pinned providers), `README.md` — and never hardcodes names/regions/accounts. The `aws` provider is configured once in the env root and inherited by the modules.

---

## Quickstart

> Prereqs: AWS CLI v2 (`lab` profile), Terraform ≥1.10, `psql`, and the pre-commit toolchain. Region: `eu-central-1`.

```bash
# 1. One-time: create the remote-state bucket (runs on local state)
cd infrastructure/bootstrap && terraform init && terraform apply
#    → copy the `state_bucket` output into envs/prod/backend.tf

# 2. Stand up the environment
cd ../../envs/prod
terraform init && terraform fmt && terraform validate
terraform plan            # free — run often
terraform apply           # deploy only when ready to test

# 3. Run the pipeline (trigger the DAG from the MWAA / Airflow UI or CLI)
#    generate → extract_delta → clean → kpi → load, config {"run_date":"2026-06-29"}

# 4. Verify, then always destroy
terraform destroy && terraform state list   # must be EMPTY
```

---

## Cost model (why it stays under $50)

| Resource | Setting | Cost at lab scale |
|---|---|---|
| S3 (4 zones) | few GB, `force_destroy=true` | ~$1/mo |
| Glue Python-shell (generate, extract, load) | 0.0625 DPU | cents |
| EMR Serverless (clean, kpi) | per-vCPU/GB-hour, auto-stops | ~$1–3 / short run |
| RDS Postgres | `db.t3.micro`, Free Tier, SG → single IP | $0 (free tier) |
| Redshift Serverless *(toggle)* | auto-pause, deleted after | ~$5 / session |
| MWAA *(toggle)* | deploy → test → **destroy** only | ~$2–5 once (~$350–400/mo if left idle) |

**Typical month ≈ $10–15 routine, ~$20–25 with a Redshift + MWAA exercise — comfortably under $50.**

---

## Build status

> Reset to a from-zero start on 2026-09-07. Full task breakdown lives in the notes' Build Checklist.

- [ ] **Foundation** — `s3` / `iam_roles` / `budget` / `rds` module scaffolds exist; remote-state bootstrap, the `envs/prod` root, and quality gates still to wire
- [ ] **Core pipeline** — RDS source → watermarked extract → EMR Spark clean/KPI → RDS load, orchestrated by MWAA
- [ ] **Three warehouses** — RDS `analytics`, Redshift Serverless (`COPY FROM S3`), Iceberg + Athena (Glue 6.0 / Iceberg v3)
- [ ] **Governance** — Lake Formation TBAC (LF-Tags, data cell filters) over the catalog
- [ ] **BI** — QuickSight vehicle-search view + KPI dashboard
- [ ] **GPS extension** *(optional)* — real-time tracking (Lambda → IoT Core/Kinesis → DynamoDB hot table → API Gateway)
- [ ] **ML extension** *(optional)* — rental risk & failure prediction chained after the KPI stage
- [ ] **Production hardening** — Multi-AZ + DR drill, Secrets Manager, CloudWatch/SNS, CI plan-on-PR

<sub>Personal learning project · fictional Faker data · built to be reproducible for well under $50/month and destroyed after every session.</sub>

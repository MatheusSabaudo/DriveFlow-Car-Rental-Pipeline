"""Airflow DAG: generate — one business day of DriveFlow ops data.

The DAG *is* the generate job: it drives the pure generators in
`scripts/generators/` (the only thing under scripts/ is fake-data creation),
assembles a full business day in dependency order, and — next step — writes it
to the RDS `ops` schema and advances `ops.watermark`.

Runs incrementally, one partition per logical date, so backfills stay
idempotent (each run_date reseeds the generators deterministically).

Also runnable standalone for local evaluation, without Airflow or a database:
    python jobs/generate.py 2026-06-29 [--json OUTDIR]
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from dataclasses import asdict
from datetime import date, datetime

# Make the pure generators (scripts/generators) importable, both in MWAA and
# locally. Override with DRIVEFLOW_SCRIPTS_DIR when scripts/ is mounted elsewhere.
SCRIPTS_DIR = os.environ.get(
    "DRIVEFLOW_SCRIPTS_DIR",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts"),
)
sys.path.insert(0, SCRIPTS_DIR)

from generators import (  # noqa: E402  (import follows the sys.path tweak above)
    BranchGenerator,
    CustomerGenerator,
    OdometerGenerator,
    RentalGenerator,
    VehicleGenerator,
    build_faker,
    rows_to_dicts,
)


# --- the generate job -------------------------------------------------------
def build_day(run_date: date) -> dict[str, list]:
    """Generate a full business day of ops data, in dependency order."""
    seed = int(run_date.strftime("%Y%m%d"))  # reproducible per business day
    fake = build_faker(seed)

    branches = BranchGenerator(run_date, fake).generate()
    vehicles = VehicleGenerator(run_date, fake).generate()
    customers = CustomerGenerator(run_date, fake).generate()
    rentals = RentalGenerator(run_date, fake, vehicles, customers, branches).generate()
    odometer = OdometerGenerator(run_date, fake, rentals).generate()

    return {
        "branch": branches,
        "vehicle": vehicles,
        "customer": customers,
        "rental": rentals,
        "odometer": odometer,
    }


def run_generate(ds: str) -> dict[str, int]:
    """Airflow task entrypoint: generate one day for logical date `ds`.

    TODO(next): write each entity into the RDS `ops` schema and advance
    `ops.watermark` in one transaction. For now it generates and logs counts.
    """
    run_date = date.fromisoformat(ds)
    day = build_day(run_date)
    counts = {name: len(rows) for name, rows in day.items()}
    print(f"[generate] run_date={ds} counts={counts}")
    return counts


# --- Airflow DAG (registered only when Airflow is importable) ---------------
try:
    from airflow import DAG
    from airflow.operators.python import PythonOperator

    with DAG(
        dag_id="generate",
        description="Generate one business day of DriveFlow ops data (Faker → RDS ops).",
        start_date=datetime(2026, 1, 1),
        schedule="@daily",
        catchup=False,
        tags=["driveflow", "ingestion"],
    ) as dag:
        PythonOperator(
            task_id="generate",
            python_callable=run_generate,
            op_args=["{{ ds }}"],  # logical date → per-day partition + seed
        )
except ImportError:
    # Airflow absent (local evaluation) — the DAG simply isn't registered.
    dag = None


# --- local evaluation harness (no Airflow, no DB) ---------------------------
def _json_default(o):
    if isinstance(o, (datetime, date)):
        return o.isoformat()
    raise TypeError(f"not serializable: {type(o)}")


def _messiness_report(day: dict[str, list], run_date: date) -> dict[str, int]:
    customers, rentals, odo = day["customer"], day["rental"], day["odometer"]
    seen: set[str] = set()
    duplicate_rentals = 0
    for r in rentals:
        if r.rental_id in seen:
            duplicate_rentals += 1
        seen.add(r.rental_id)
    return {
        "malformed_emails": sum("@" not in c.email or c.email.endswith("@") for c in customers),
        "open_rentals": sum(r.end_ts is None for r in rentals),
        "future_start_rentals": sum(r.start_ts.date() > run_date for r in rentals),
        "end_before_start": sum(r.end_ts is not None and r.end_ts < r.start_ts for r in rentals),
        "duplicate_rentals": duplicate_rentals,
        "negative_odometer": sum(o.odometer_reading_km < 0 for o in odo),
        "out_of_range_fuel": sum(not 0 <= o.fuel_level_percentage <= 100 for o in odo),
    }


def _main() -> None:
    parser = argparse.ArgumentParser(description="Generate one day of DriveFlow ops data (local eval).")
    parser.add_argument("run_date", nargs="?", default=date.today().isoformat(),
                        help="business day as YYYY-MM-DD (default: today)")
    parser.add_argument("--json", metavar="OUTDIR", help="also write <entity>.json into OUTDIR")
    args = parser.parse_args()

    run_date = date.fromisoformat(args.run_date)
    day = build_day(run_date)

    print(f"\nDriveFlow generation — run_date={run_date.isoformat()}\n" + "-" * 44)
    for name, rows in day.items():
        print(f"  {name:<10} {len(rows):>6} rows")

    print("\nInjected messiness\n" + "-" * 44)
    for k, v in _messiness_report(day, run_date).items():
        print(f"  {k:<22} {v:>6}")

    print("\nSample rows\n" + "-" * 44)
    for name, rows in day.items():
        print(f"\n[{name}]")
        for row in rows[:2]:
            print("  " + json.dumps(asdict(row), default=_json_default, ensure_ascii=False))

    if args.json:
        os.makedirs(args.json, exist_ok=True)
        for name, rows in day.items():
            with open(os.path.join(args.json, f"{name}.json"), "w", encoding="utf-8") as fh:
                json.dump(rows_to_dicts(rows), fh, default=_json_default, ensure_ascii=False, indent=2)
        print(f"\nWrote JSON for {len(day)} entities → {args.json}/")


if __name__ == "__main__":
    _main()

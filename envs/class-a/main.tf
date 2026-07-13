# envs/class-a/main.tf

data "aws_caller_identity" "current" {}

locals {
  # driveflow-class-a  (project is fixed for this repo; env comes from the var)
  name_prefix = "driveflow-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id
}

# ── Foundation 1: S3 data lake (raw / cleansed / curated / scripts) ──
module "lake" {
  source = "../../modules/s3"

  raw_bucket_name      = "${local.name_prefix}-raw-${local.account_id}"
  cleansed_bucket_name = "${local.name_prefix}-cleansed-${local.account_id}"
  curated_bucket_name  = "${local.name_prefix}-curated-${local.account_id}"
  scripts_bucket_name  = "${local.name_prefix}-scripts-${local.account_id}"
}

# ── Foundation 2: IAM roles (Glue + Step Functions) ──
module "iam" {
  source = "../../modules/iam_roles"
}

# ── Foundation 3: Budget + alerts ($50, 50/80/100% + forecast) ──
module "budget" {
  source = "../../modules/budget"

  email = var.budget_email
}

# ── Networking: default-VPC lookup + DB subnet group (free) ──
module "vpc" {
  source = "../../modules/vpc"
}

# ── Class A: RDS Postgres (gated; off by default) ──
module "rds" {
  source = "../../modules/rds"
  count  = var.enable_rds ? 1 : 0

  ip_cidr              = var.ip_cidr
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
}

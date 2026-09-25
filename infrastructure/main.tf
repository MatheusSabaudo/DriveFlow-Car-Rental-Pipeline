data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project}-dev"

  tags = {
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

# --- Shared resources ---

module "vpc" {
  source = "./modules/vpc"
}

module "iam_roles" {
  source                 = "./modules/iam_roles"
  mwaa_environment_name  = local.name_prefix
  mwaa_source_bucket_arn = module.s3.mwaa_source_bucket_arn
}

module "s3" {
  source      = "./modules/s3"
}

module "mwaa" {
  source = "./modules/mwaa"
  name = local.name_prefix
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  execution_role_arn = module.iam_roles.mwaa_role_arn
  source_bucket_arn = module.s3.mwaa_source_bucket_arn
}

module "sns" {
  source      = "./modules/sns"
  topic_name  = "${local.name_prefix}-alerts"
  alert_email = var.sns_alert_email
}


# module "eventbridge" {
#   for_each            = local.deploy_retriever
#   source              = "./modules/eventbridge"
#   name_prefix         = local.name_prefix
#   schedule_name       = "${local.name_prefix}-lambda-scheduler"
#   lambda_function_arn = module.lambda_retriever["this"].function_arn
# }


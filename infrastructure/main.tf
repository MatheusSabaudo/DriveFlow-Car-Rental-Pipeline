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


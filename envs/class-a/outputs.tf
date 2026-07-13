# envs/class-a/outputs.tf

output "raw_bucket" {
  value = module.lake.raw_bucket_name
}

output "cleansed_bucket" {
  value = module.lake.cleansed_bucket_name
}

output "curated_bucket" {
  value = module.lake.curated_bucket_name
}

output "scripts_bucket" {
  value = module.lake.scripts_bucket_name
}

output "glue_role_arn" {
  value = module.iam.glue_role_arn
}

output "step_functions_role_arn" {
  value = module.iam.step_functions_role_arn
}

output "budget_name" {
  value = module.budget.budget_name
}

output "rds_endpoint" {
  description = "RDS endpoint (null when enable_rds = false)"
  value       = try(module.rds[0].db_endpoint, null)
}

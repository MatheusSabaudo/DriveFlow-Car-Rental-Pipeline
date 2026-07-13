output "glue_role_arn" {
  value = aws_iam_role.glue_service_role.arn
}

output "glue_role_name" {
  value = aws_iam_role.glue_service_role.name
}

output "step_functions_role_arn" {
  value = aws_iam_role.step_functions_role.arn
}

output "step_functions_role_name" {
  value = aws_iam_role.step_functions_role.name
}

output "emr_role_arn" {
  value = aws_iam_role.emr_service_role.arn
}

output "emr_role_name" {
  value = aws_iam_role.emr_service_role.name
}

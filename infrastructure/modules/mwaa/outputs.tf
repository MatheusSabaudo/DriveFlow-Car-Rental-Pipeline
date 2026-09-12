output "arn" {
  description = "ARN of the MWAA environment."
  value       = aws_mwaa_environment.this.arn
}

output "name" {
  description = "Name of the MWAA environment."
  value       = aws_mwaa_environment.this.name
}

output "webserver_url" {
  description = "Airflow web UI URL."
  value       = aws_mwaa_environment.this.webserver_url
}

output "security_group_id" {
  description = "ID of the self-referencing MWAA security group."
  value       = aws_security_group.mwaa.id
}

output "status" {
  description = "Lifecycle status of the MWAA environment."
  value       = aws_mwaa_environment.this.status
}

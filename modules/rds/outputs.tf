output "db_instance_identifier" {
  value = aws_db_instance.postgres_rds_instance.identifier
}

output "db_endpoint" {
  description = "host:port endpoint"
  value       = aws_db_instance.postgres_rds_instance.endpoint
}

output "db_address" {
  description = "Hostname only"
  value       = aws_db_instance.postgres_rds_instance.address
}

output "db_port" {
  value = aws_db_instance.postgres_rds_instance.port
}

output "db_name" {
  value = aws_db_instance.postgres_rds_instance.db_name
}

output "security_group_id" {
  value = aws_security_group.rds.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN for the managed master password"
  value       = try(aws_db_instance.postgres_rds_instance.master_user_secret[0].secret_arn, null)
}

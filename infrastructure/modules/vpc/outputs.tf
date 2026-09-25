output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "private_subnet_ids" {
  description = "The two private subnet IDs (for MWAA / anything needing private subnets)."
  value       = aws_subnet.private[*].id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

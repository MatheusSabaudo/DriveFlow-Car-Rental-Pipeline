output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

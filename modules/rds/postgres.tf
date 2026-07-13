# ------------- RDS -----------------------------------------------------

# RDS instance with IAM authentication enabled
resource "aws_db_instance" "postgres_rds_instance" {
  identifier     = "postgres-operational-source"
  db_name        = var.db_name
  engine         = "postgres"
  engine_version = "18.3"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 50

  storage_type      = "gp3"
  storage_encrypted = true

  manage_master_user_password = true
  username                    = var.db_username

  skip_final_snapshot = true

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_time_window
  maintenance_window      = var.maintenance_time_window

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  iam_database_authentication_enabled = true

  multi_az            = false
  publicly_accessible = true

  parameter_group_name = aws_db_parameter_group.iam_auth.name

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  copy_tags_to_snapshot = true

  tags = {
    Name      = var.db_name
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "rds-sg"
  vpc_id      = var.vpc_id
  description = "RDS with IAM authentication"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.ip_cidr]
    description = "Allow access to the database from the specified IP range"
  }

  tags = {
    Name      = "rds-iam-sg"
  }
}


# Parameter group enforcing SSL (required for IAM authentication)
resource "aws_db_parameter_group" "iam_auth" {
  name   = "iam-auth-params"
  family = "postgres18"

  tags = {
    Name      = "IAM Auth Params"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}
# Amazon MWAA (Managed Airflow) environment + its required VPC wiring.

resource "aws_security_group" "mwaa" {
  name_prefix = "${var.name}-"
  vpc_id      = var.vpc_id
  description = "MWAA environment security group (self-referencing)"

  tags = merge(var.tags, { Name = "${var.name}-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

# Self-reference: allow all traffic between members of this SG (MWAA components).
resource "aws_vpc_security_group_ingress_rule" "self" {
  security_group_id            = aws_security_group.mwaa.id
  referenced_security_group_id = aws_security_group.mwaa.id
  ip_protocol                  = "-1"
  description                  = "Allow all traffic within the MWAA security group"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.mwaa.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound (AWS APIs, PyPI via NAT/endpoints)"
}

resource "aws_mwaa_environment" "this" {
  name               = var.name
  airflow_version    = var.airflow_version
  environment_class  = var.environment_class
  dag_s3_path        = var.dag_s3_path
  source_bucket_arn  = var.source_bucket_arn
  execution_role_arn = var.execution_role_arn

  webserver_access_mode = var.webserver_access_mode
  min_workers           = var.min_workers
  max_workers           = var.max_workers

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = var.subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = var.log_level
    }
    scheduler_logs {
      enabled   = true
      log_level = var.log_level
    }
    task_logs {
      enabled   = true
      log_level = var.log_level
    }
    webserver_logs {
      enabled   = true
      log_level = var.log_level
    }
    worker_logs {
      enabled   = true
      log_level = var.log_level
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

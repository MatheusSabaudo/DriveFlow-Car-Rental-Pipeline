data "aws_vpc" "main" { default = true }

resource "aws_db_subnet_group" "main" {
  name       = "driveflow-rds-subnets"
  subnet_ids = data.aws_subnets.default.ids
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}


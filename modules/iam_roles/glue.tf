# Glue IAM Role

resource "aws_iam_role" "glue_service_role" {
  name = "glue-service-role"

  tags = {
    Name      = "Glue Service Role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "glue.amazonaws.com" }
      }
    ]
  })
}
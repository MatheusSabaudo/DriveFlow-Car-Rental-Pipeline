# EMR IAM Role

resource "aws_iam_role" "emr_service_role" {
  name = "emr-service-role"

  tags = {
    Name      = "EMR Service Role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "emr.amazonaws.com" }
      }
    ]
  })
}
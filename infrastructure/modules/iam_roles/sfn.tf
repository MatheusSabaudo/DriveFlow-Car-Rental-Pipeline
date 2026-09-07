# Step Functions execution role

resource "aws_iam_role" "step_functions_role" {
  name = "step-functions-execution-role"

  tags = {
    Name      = "Step Functions Execution Role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "states.amazonaws.com" }
      }
    ]
  })
}
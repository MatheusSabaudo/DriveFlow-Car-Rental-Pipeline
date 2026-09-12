# MWAA execution role — assumed by the Airflow environment (scheduler, workers,
# webserver). Scoped to exactly what MWAA needs to operate: read the DAG bucket,
# write its own log group, publish its metrics, and use its Celery SQS queue.
# Task-specific permissions (e.g. glue:StartJobRun, EMR) are added separately
# when those operators exist — kept out of here to preserve least privilege.

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  mwaa_env_arn = "arn:${data.aws_partition.current.partition}:airflow:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:environment/${var.mwaa_environment_name}"
  mwaa_log_arn = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.mwaa_environment_name}-*"
  mwaa_sqs_arn = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.region}:*:airflow-celery-*"
  kms_key_arn  = "arn:${data.aws_partition.current.partition}:kms:*:${data.aws_caller_identity.current.account_id}:key/*"
}

resource "aws_iam_role" "mwaa_execution_role" {
  name = "mwaa-execution-role"

  tags = {
    Name = "MWAA Execution Role"
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = ["airflow.amazonaws.com", "airflow-env.amazonaws.com"] }
      }
    ]
  })
}

resource "aws_iam_role_policy" "mwaa_execution_policy" {
  name = "mwaa-execution-policy"
  role = aws_iam_role.mwaa_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PublishAirflowMetrics"
        Effect   = "Allow"
        Action   = "airflow:PublishMetrics"
        Resource = local.mwaa_env_arn
      },
      {
        Sid      = "DenyListAllBuckets"
        Effect   = "Deny"
        Action   = "s3:ListAllMyBuckets"
        Resource = [var.mwaa_source_bucket_arn, "${var.mwaa_source_bucket_arn}/*"]
      },
      {
        Sid      = "ReadDagBucket"
        Effect   = "Allow"
        Action   = ["s3:GetObject*", "s3:GetBucket*", "s3:List*"]
        Resource = [var.mwaa_source_bucket_arn, "${var.mwaa_source_bucket_arn}/*"]
      },
      {
        Sid    = "WriteEnvironmentLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults",
        ]
        Resource = [local.mwaa_log_arn]
      },
      {
        Sid      = "DescribeLogGroups"
        Effect   = "Allow"
        Action   = "logs:DescribeLogGroups"
        Resource = "*"
      },
      {
        Sid      = "PublishCloudWatchMetrics"
        Effect   = "Allow"
        Action   = "cloudwatch:PutMetricData"
        Resource = "*"
      },
      {
        Sid    = "UseCeleryQueue"
        Effect = "Allow"
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
        ]
        Resource = local.mwaa_sqs_arn
      },
      {
        Sid    = "DecryptSqsWithAwsManagedKey"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt",
        ]
        NotResource = local.kms_key_arn
        Condition = {
          StringLike = {
            "kms:ViaService" = ["sqs.${data.aws_region.current.region}.amazonaws.com"]
          }
        }
      },
    ]
  })
}

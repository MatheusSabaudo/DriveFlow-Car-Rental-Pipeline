variable "mwaa_environment_name" {
  description = "Name of the MWAA environment the execution role is scoped to (must match the mwaa module's `name`)."
  type        = string
  default     = "driveflow-dev-mwaa"
}

variable "mwaa_source_bucket_arn" {
  description = "ARN of the S3 bucket holding MWAA DAGs/requirements/plugins; the execution role gets read access to it only."
  type        = string
}

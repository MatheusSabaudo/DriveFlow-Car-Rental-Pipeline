variable "name" {
  description = "Name of the MWAA environment."
  type        = string
  default     = "driveflow-dev-mwaa"
}

variable "vpc_id" {
  description = "VPC the MWAA environment (and its security group) lives in."
  type        = string
}

variable "subnet_ids" {
  description = "Exactly two PRIVATE subnets in different AZs for MWAA."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) == 2
    error_message = "MWAA requires exactly two private subnets in different AZs."
  }
}

variable "source_bucket_arn" {
  description = "ARN of the (versioned) S3 bucket holding dags/, requirements.txt, plugins."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the MWAA execution role (see modules/iam_roles/mwaa.tf)."
  type        = string
}

variable "dag_s3_path" {
  description = "Path within the source bucket where DAGs live."
  type        = string
  default     = "dags/"
}

variable "environment_class" {
  description = "MWAA environment size."
  type        = string
  default     = "mw1.small"
}

variable "airflow_version" {
  description = "Airflow version; null lets AWS pick the current default."
  type        = string
  default     = null
}

variable "min_workers" {
  description = "Minimum number of Airflow workers."
  type        = number
  default     = 1
}

variable "max_workers" {
  description = "Maximum number of Airflow workers."
  type        = number
  default     = 2
}

variable "webserver_access_mode" {
  description = "PUBLIC_ONLY (UI over the internet, IAM-authed) or PRIVATE_ONLY (needs VPC endpoints)."
  type        = string
  default     = "PUBLIC_ONLY"

  validation {
    condition     = contains(["PUBLIC_ONLY", "PRIVATE_ONLY"], var.webserver_access_mode)
    error_message = "webserver_access_mode must be PUBLIC_ONLY or PRIVATE_ONLY."
  }
}

variable "log_level" {
  description = "Log level applied to all MWAA log streams."
  type        = string
  default     = "INFO"
}

variable "tags" {
  description = "Additional tags to apply to MWAA resources."
  type        = map(string)
  default     = {}
}

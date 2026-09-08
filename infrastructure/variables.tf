variable "project" {
  description = "Project name used as prefix for all resource names and tags"
  type        = string
  default     = "driveflow"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "sns_alert_email" {
  description = "Email endpoint for SNS alerts (empty = no subscription)"
  type        = string
  default     = ""
}
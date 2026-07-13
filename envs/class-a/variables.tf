variable "aws_profile" {
    description = "AWS CLI profile to use for authentication"
    type        = string
    default     = "lab28"
}

variable "aws_region" {
    description = "AWS region to deploy into"
    type        = string
    default     = "eu-central-1"
}

variable "environment" {
    description = "Environment / delivery class name (used in tags + naming)"
    type        = string
    default     = "class-a"
}

variable "ip_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "budget_email" {
    description = "Email address for budget alerts"
    type        = string
    default     = "matheus.sabaudo@corley.it"
}

variable "enable_rds" {
    description = "Whether to enable RDS resources"
    type        = bool
    default     = false
}

variable "enable_redshift" {
    description = "Whether to enable Redshift resources"
    type        = bool
    default     = false
}

variable "enable_emr" {
    description = "Whether to enable EMR resources"
    type        = bool
    default     = false
}

variable "enable_mwaa" {
    description = "Whether to enable MWAA resources"
    type        = bool
    default     = false
}

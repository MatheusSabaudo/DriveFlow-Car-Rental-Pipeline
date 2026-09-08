variable "aws_region" {
    description = "The AWS region to deploy resources in."
    type        = string
    default     = "eu-central-1"
}

variable "environment" {
    description = "The environment for the deployment (e.g., dev, staging, prod)."
    type        = string
    default     = "dev"
}

variable "terraform_state" {
    description = "The name of the S3 bucket to store Terraform state."
    type        = string
    default     = "driveflow-terraform-state"
}
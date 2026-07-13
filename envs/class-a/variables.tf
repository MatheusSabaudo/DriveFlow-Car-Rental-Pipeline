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

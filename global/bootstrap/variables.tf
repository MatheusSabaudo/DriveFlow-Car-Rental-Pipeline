variable aws_profile {
    description = "The AWS profile to use for authentication"
    type        = string
    default     = "lab28"
}

variable environment {
    description = "The environment to deploy to"
    type        = string
    default     = "lab28"
}

variable aws_region {
    description = "The AWS region to deploy to"
    type        = string
    default     = "eu-central-1"
}
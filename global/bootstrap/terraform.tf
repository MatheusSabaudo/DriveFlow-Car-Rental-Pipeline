terraform {
    required_version = ">= 1.0.0"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

provider "aws" {
    region  = var.aws_region
    profile = var.aws_profile

default_tags {
        tags = {
            Terraform   = "true"
            Project     = "driveflow"
            Service     = "driveflow"
            Environment = var.environment
            Team        = "data-engineering"
            repository  = "MatheusSabaudo/DriveFlow-Car-Rental-Pipeline"
        }
    }
}



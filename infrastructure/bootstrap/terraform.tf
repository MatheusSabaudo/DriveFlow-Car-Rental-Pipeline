# Business-ready (Gold) bucket
resource "aws_s3_bucket" "s3-bucket-ready" {
  bucket        = var.terraform_state
  force_destroy = false

  tags = {
    Name      = "Terraform State Bucket"
  }
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
  }

  backend "s3" {
    bucket       = "driveflow-terraform-state"
    key          = "infrastructure/terraform.tfstate"
    region       = "eu-central-1"
    profile      = "lab28"
    encrypt      = true
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "lab28"

  default_tags {
    tags = {
      Project     = "solar-pipeline"
      Service     = "solar-pipeline"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = "data-engineering"
      Repository  = "MatheusSabaudoCorley/DriveFlow-Car-Rental-Pipeline"
    }
  }
}
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

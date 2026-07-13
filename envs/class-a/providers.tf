# The ONE place the aws provider is configured. Every module called from this
# root inherits this configuration (region, profile, default_tags) — which is
# why modules only declare `required_providers`, never a `provider` block.
# default_tags stamps every resource → powers budget filtering + cleanup.

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

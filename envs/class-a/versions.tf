# Root required_providers. Terraform merges this terraform{} block with the
# one in backend.tf (which holds required_version + the s3 backend).

terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

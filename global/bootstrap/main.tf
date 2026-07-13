# S3 bucket for terraform state storage.

data "aws_caller_identity" "current" {}

locals {
    # globally-unique name via the account id suffix
    state_bucket_name = "driveflow-tfstate-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "tfstate" {
    bucket = local.state_bucket_name

    # state history should not be wiped by an accidental destroy
    force_destroy = false
}

resource "aws_s3_bucket_versioning" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id

    versioning_configuration {
        status = "Enabled"
    }
}

# Encrypt state at rest — it can hold secrets (DB passwords, etc.) in plaintext.
# SSE-S3 (AES256) needs no KMS key and is free
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# State must never be public.
resource "aws_s3_bucket_public_access_block" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}


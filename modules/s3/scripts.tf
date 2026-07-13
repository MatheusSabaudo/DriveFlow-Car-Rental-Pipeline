# -------------- SCRIPTS S3 BUCKET --------------------------------------------

resource "aws_s3_bucket" "bucket_scripts" {

    bucket = var.scripts_bucket_name
    force_destroy = true

    tags = {
        Name        = var.scripts_bucket_name
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_scripts" {

    bucket = aws_s3_bucket.bucket_scripts.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_scripts" {

    bucket = aws_s3_bucket.bucket_scripts.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

# S3 SSE-S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_scripts" {

    bucket = aws_s3_bucket.bucket_scripts.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "s3_bucket_scripts_tls_enforcement" {

  bucket = aws_s3_bucket.bucket_scripts.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.bucket_scripts.arn}/*",
          aws_s3_bucket.bucket_scripts.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# -------------- END SCRIPTS S3 BUCKET ---------------------------------------
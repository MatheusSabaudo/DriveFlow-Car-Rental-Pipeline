# Bronze layer

resource "aws_s3_bucket" "bronze_layer_bucket" {
  bucket        = var.bronze_layer_bucket_name
  force_destroy = true

  tags = {
    Name      = "Bucket Business Ready"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_ready_public_access_block" {
  bucket                  = aws_s3_bucket.bronze_layer_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3_bucket_ready_versioning" {
  bucket = aws_s3_bucket.bronze_layer_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_ready_encryption" {
  bucket = aws_s3_bucket.bronze_layer_bucket.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_ready_tls_enforcement" {
  bucket = aws_s3_bucket.bronze_layer_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.bronze-layer-bucket.arn}/*",
          aws_s3_bucket.bronze-layer-bucket.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_ready_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.s3_bucket_ready_versioning]
  bucket     = aws_s3_bucket.bronze_layer_bucket.id

  rule {
    id     = "all-objects-lifecycle-rule"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}
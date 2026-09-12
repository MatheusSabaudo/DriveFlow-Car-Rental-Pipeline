# Bronze layer

resource "aws_s3_bucket" "bronze_layer_bucket" {
  bucket        = var.bronze_layer_bucket_name
  force_destroy = true

  tags = {
    Name      = "Bronze Layer Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "bronze_layer_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.bronze_layer_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bronze_layer_bucket_versioning" {
  bucket = aws_s3_bucket.bronze_layer_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bronze_layer_bucket_encryption" {
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
          "${aws_s3_bucket.bronze_layer_bucket.arn}/*",
          aws_s3_bucket.bronze_layer_bucket.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "bronze_layer_bucket_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.bronze_layer_bucket_versioning]
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



# Silver layer
resource "aws_s3_bucket" "silver_layer_bucket" {
  bucket        = var.silver_layer_bucket_name
  force_destroy = true

  tags = {
    Name      = "Silver Layer Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "silver_layer_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.silver_layer_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "silver_layer_bucket_versioning" {
  bucket = aws_s3_bucket.silver_layer_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "silver_layer_bucket_encryption" {
  bucket = aws_s3_bucket.silver_layer_bucket.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_silver_tls_enforcement" {
  bucket = aws_s3_bucket.silver_layer_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.silver_layer_bucket.arn}/*",
          aws_s3_bucket.silver_layer_bucket.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "silver_layer_bucket_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.silver_layer_bucket_versioning]
  bucket     = aws_s3_bucket.silver_layer_bucket.id

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


# Gold layer
resource "aws_s3_bucket" "gold_layer_bucket" {
  bucket        = var.gold_layer_bucket_name
  force_destroy = true

  tags = {
    Name      = "Gold Layer Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "gold_layer_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.gold_layer_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "gold_layer_bucket_versioning" {
  bucket = aws_s3_bucket.gold_layer_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gold_layer_bucket_encryption" {
  bucket = aws_s3_bucket.gold_layer_bucket.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_policy" "gold_layer_bucket_tls_enforcement" {
  bucket = aws_s3_bucket.gold_layer_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.gold_layer_bucket.arn}/*",
          aws_s3_bucket.gold_layer_bucket.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "gold_layer_bucket_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.gold_layer_bucket_versioning]
  bucket     = aws_s3_bucket.gold_layer_bucket.id

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



# Glue scripts bucket
resource "aws_s3_bucket" "glue_scripts_bucket" {
  bucket        = var.glue_scripts_bucket_name
  force_destroy = true

  tags = {
    Name      = "Bucket Glue Scripts"
  }
}

resource "aws_s3_bucket_public_access_block" "glue_scripts_public_access_block" {
  bucket                  = aws_s3_bucket.glue_scripts_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "glue_scripts_versioning" {
  bucket = aws_s3_bucket.glue_scripts_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "glue_scripts_encryption" {
  bucket = aws_s3_bucket.glue_scripts_bucket.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_policy" "glue_scripts_tls_enforcement" {
  bucket = aws_s3_bucket.glue_scripts_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.glue_scripts_bucket.arn}/*",
          aws_s3_bucket.glue_scripts_bucket.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "glue_scripts_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.glue_scripts_versioning]
  bucket     = aws_s3_bucket.glue_scripts_bucket.id

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

# Glue temp bucket
resource "aws_s3_bucket" "glue_temp_bucket" {
  bucket        = var.glue_temp_bucket_name
  force_destroy = true

  tags = {
    Name      = "Bucket Glue Temp"
  }
}

resource "aws_s3_bucket_public_access_block" "glue_temp_public_access_block" {
  bucket                  = aws_s3_bucket.glue_temp_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "glue_temp_versioning" {
  bucket = aws_s3_bucket.glue_temp_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "glue_temp_encryption" {
  bucket = aws_s3_bucket.glue_temp_bucket.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_policy" "glue_temp_tls_enforcement" {
  bucket = aws_s3_bucket.glue_temp_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.glue_temp_bucket.arn}/*",
          aws_s3_bucket.glue_temp_bucket.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "glue_temp_lifecycle" {
  depends_on = [aws_s3_bucket_versioning.glue_temp_versioning]
  bucket     = aws_s3_bucket.glue_temp_bucket.id

  rule {
    id     = "all-objects-lifecycle-rule"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    # Temp scratch files — non-current versions have no value, delete immediately
    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    status = "Enabled"
  }
}
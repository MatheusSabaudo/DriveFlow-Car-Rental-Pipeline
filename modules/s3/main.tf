# -------------- RAW S3 BUCKET -------------------------------------------

resource "aws_s3_bucket" "bucket_raw" {

    bucket = var.raw_bucket_name
    force_destroy = true

    tags = {
        Name        = var.raw_bucket_name
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_raw" {

    bucket = aws_s3_bucket.bucket_raw.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_raw" {

    bucket = aws_s3_bucket.bucket_raw.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

# Pending analysis

# resource "aws_s3_bucket_lifecycle_configuration" "bucket_raw" {
#     bucket = aws_s3_bucket.bucket_raw.id

#     rule {
#         id     = "raw-bucket-lifecycle-rule"
#         status = "Enabled"

#         expiration {
#             days = 30
#         }
#     }
# }

# S3 SSE-S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_raw" {

    bucket = aws_s3_bucket.bucket_raw.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "s3_bucket_raw_tls_enforcement" {

  bucket = aws_s3_bucket.bucket_raw.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.bucket_raw.arn}/*",
          aws_s3_bucket.bucket_raw.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# -------------- END RAW S3 BUCKET -------------------------------------------

# -------------- CLEANSED S3 BUCKET ------------------------------------------

resource "aws_s3_bucket" "bucket_cleansed" {

    bucket = var.cleansed_bucket_name
    force_destroy = true

    tags = {
        Name        = var.cleansed_bucket_name
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_cleansed" {

    bucket = aws_s3_bucket.bucket_cleansed.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_cleansed" {

    bucket = aws_s3_bucket.bucket_cleansed.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

# Pending analysis

# resource "aws_s3_bucket_lifecycle_configuration" "bucket_cleansed" {
#     bucket = aws_s3_bucket.bucket_cleansed.id

#     rule {
#         id     = "cleansed-bucket-lifecycle-rule"
#         status = "Enabled"

#         expiration {
#             days = 30
#         }
#     }
# }

# S3 SSE-S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_cleansed" {

    bucket = aws_s3_bucket.bucket_cleansed.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "s3_bucket_cleansed_tls_enforcement" {

  bucket = aws_s3_bucket.bucket_cleansed.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.bucket_cleansed.arn}/*",
          aws_s3_bucket.bucket_cleansed.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# -------------- END CLEANSED S3 BUCKET ---------------------------------------

# -------------- CURATED S3 BUCKET --------------------------------------------

resource "aws_s3_bucket" "bucket_curated" {

    bucket = var.curated_bucket_name
    force_destroy = true

    tags = {
        Name        = var.curated_bucket_name
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_curated" {

    bucket = aws_s3_bucket.bucket_curated.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_curated" {

    bucket = aws_s3_bucket.bucket_curated.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

# Pending analysis

# resource "aws_s3_bucket_lifecycle_configuration" "bucket_cleansed" {
#     bucket = aws_s3_bucket.bucket_cleansed.id

#     rule {
#         id     = "cleansed-bucket-lifecycle-rule"
#         status = "Enabled"

#         expiration {
#             days = 30
#         }
#     }
# }

# S3 SSE-S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_curated" {

    bucket = aws_s3_bucket.bucket_curated.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "s3_bucket_curated_tls_enforcement" {

  bucket = aws_s3_bucket.bucket_curated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.bucket_curated.arn}/*",
          aws_s3_bucket.bucket_curated.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# -------------- END CURATED S3 BUCKET --------------------------------------------

# -------------- SCRIPTS S3 BUCKET ------------------------------------------------

resource "aws_s3_bucket" "bucket_cleansed" {

    bucket = var.cleansed_bucket_name
    force_destroy = true

    tags = {
        Name        = var.cleansed_bucket_name
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_cleansed" {

    bucket = aws_s3_bucket.bucket_cleansed.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_cleansed" {

    bucket = aws_s3_bucket.bucket_cleansed.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

# Pending analysis

# resource "aws_s3_bucket_lifecycle_configuration" "bucket_cleansed" {
#     bucket = aws_s3_bucket.bucket_cleansed.id

#     rule {
#         id     = "cleansed-bucket-lifecycle-rule"
#         status = "Enabled"

#         expiration {
#             days = 30
#         }
#     }
# }

# S3 SSE-S3 Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_cleansed" {

    bucket = aws_s3_bucket.bucket_cleansed.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_policy" "s3_bucket_cleansed_tls_enforcement" {

  bucket = aws_s3_bucket.bucket_cleansed.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.bucket_cleansed.arn}/*",
          aws_s3_bucket.bucket_cleansed.arn
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}

# -------------- END CLEANSED S3 BUCKET ---------------------------------------

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
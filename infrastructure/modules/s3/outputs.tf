output "raw_bucket_name" {
  description = "Name of the raw bucket"
  value       = aws_s3_bucket.bucket_raw.bucket
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.bucket_raw.arn
}

output "cleansed_bucket_name" {
  value = aws_s3_bucket.bucket_cleansed.bucket
}

output "cleansed_bucket_arn" {
  value = aws_s3_bucket.bucket_cleansed.arn
}

output "curated_bucket_name" {
  value = aws_s3_bucket.bucket_curated.bucket
}

output "curated_bucket_arn" {
  value = aws_s3_bucket.bucket_curated.arn
}

output "scripts_bucket_name" {
  value = aws_s3_bucket.bucket_scripts.bucket
}

output "scripts_bucket_arn" {
  value = aws_s3_bucket.bucket_scripts.arn
}

output "bucket_arns" {
  description = "All data-lake bucket ARNs (for IAM least-privilege policies)"
  value = [
    aws_s3_bucket.bucket_raw.arn,
    aws_s3_bucket.bucket_cleansed.arn,
    aws_s3_bucket.bucket_curated.arn,
    aws_s3_bucket.bucket_scripts.arn,
  ]
}

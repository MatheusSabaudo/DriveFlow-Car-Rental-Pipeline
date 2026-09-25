output "bronze_bucket_name" {
  description = "Name of the bronze layer bucket"
  value       = aws_s3_bucket.bronze_layer_bucket.bucket
}

output "bronze_bucket_arn" {
  value = aws_s3_bucket.bronze_layer_bucket.arn
}

output "silver_bucket_name" {
  value = aws_s3_bucket.silver_layer_bucket.bucket
}

output "silver_bucket_arn" {
  value = aws_s3_bucket.silver_layer_bucket.arn
}

output "gold_bucket_name" {
  value = aws_s3_bucket.gold_layer_bucket.bucket
}

output "gold_bucket_arn" {
  value = aws_s3_bucket.gold_layer_bucket.arn
}

output "glue_scripts_bucket_name" {
  value = aws_s3_bucket.glue_scripts_bucket.bucket
}

output "glue_scripts_bucket_arn" {
  value = aws_s3_bucket.glue_scripts_bucket.arn
}

output "glue_temp_bucket_name" {
  value = aws_s3_bucket.glue_temp_bucket.bucket
}

output "glue_temp_bucket_arn" {
  value = aws_s3_bucket.glue_temp_bucket.arn
}

output "mwaa_source_bucket_name" {
  value = aws_s3_bucket.mwaa_source_bucket.bucket
}

output "mwaa_source_bucket_arn" {
  value = aws_s3_bucket.mwaa_source_bucket.arn
}

output "bucket_arns" {
  description = "All data-lake bucket ARNs (for IAM least-privilege policies)"
  value = [
    aws_s3_bucket.bronze_layer_bucket.arn,
    aws_s3_bucket.silver_layer_bucket.arn,
    aws_s3_bucket.gold_layer_bucket.arn,
    aws_s3_bucket.glue_scripts_bucket.arn,
    aws_s3_bucket.glue_temp_bucket.arn,
  ]
}

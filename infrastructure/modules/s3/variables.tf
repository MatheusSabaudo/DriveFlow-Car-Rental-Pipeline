variable "bronze_layer_bucket_name" {
    description = "Name of the bronze layer S3 bucket"
    type        = string
    default     = "driveflow-bronze"
}

variable "silver_layer_bucket_name" {
    description = "Name of the silver layer S3 bucket"
    type        = string
    default     = "driveflow-silver"
}

variable "gold_layer_bucket_name" {
    description = "Name of the gold layer S3 bucket"
    type        = string
    default     = "driveflow-gold"
}

variable "scripts_bucket_name" {
    description = "Name of the scripts S3 bucket"
    type        = string
    default     = "driveflow-scripts"
}
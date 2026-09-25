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

variable "glue_scripts_bucket_name" {
    description = "Name of the Glue scripts S3 bucket"
    type        = string
    default     = "driveflow-scripts"
}

variable "glue_temp_bucket_name" {
    description = "Name of the Glue temp S3 bucket"
    type        = string
    default     = "driveflow-temp"
}

variable "mwaa_source_bucket_name" {
    description = "Name of the MWAA source S3 bucket"
    type        = string
    default     = "driveflow-mwaa-source"
}
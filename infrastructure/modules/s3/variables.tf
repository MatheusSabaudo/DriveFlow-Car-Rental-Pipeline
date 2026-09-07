variable "raw_bucket_name" {
    description = "Name of the raw S3 bucket"
    type        = string
    default     = "driveflow-raw"
}

variable "cleansed_bucket_name" {
    description = "Name of the cleansed S3 bucket"
    type        = string
    default     = "driveflow-cleansed"
}

variable "curated_bucket_name" {
    description = "Name of the curated S3 bucket"
    type        = string
    default     = "driveflow-curated"
}

variable "scripts_bucket_name" {
    description = "Name of the scripts S3 bucket"
    type        = string
    default     = "driveflow-scripts"
}
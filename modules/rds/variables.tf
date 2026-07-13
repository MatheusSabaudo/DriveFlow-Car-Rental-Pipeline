variable "db_name" {
    description = "Name of the RDS database"
    type        = string
    default     = "operational-db-driveflow"
}

variable "db_username" {
    description = "Username for the RDS database"
    type        = string
    default     = "admin"
}

variable "backup_retention_period" {
    description = "Number of days to retain backups for the RDS instance"
    type        = number
    default     = 7
}

variable "backup_time_window" {
    description = "Preferred backup window for the RDS instance (in UTC)"
    type        = string
    default     = "03:00-04:00"
}

variable "maintenance_time_window" {
    description = "Preferred maintenance window for the RDS instance (in UTC)"
    type        = string
    default     = "Mon:04:00-Mon:05:00"
}

variable "ip_cidr" {
    description = "CIDR allowed to reach Postgres on 5432 (your IP /32)"
    type        = string
    # No default: with publicly_accessible = true, a 0.0.0.0/0 fallback would
    # expose the DB to the internet. Force the caller to supply it.
}

variable "vpc_id" {
    description = "ID of the VPC the RDS security group lives in"
    type        = string
}

variable "db_subnet_group_name" {
    description = "Name of the DB subnet group for the RDS instance"
    type        = string
}
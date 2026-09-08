variable "topic_name" {
  description = "Name of the SNS alerts topic"
  type        = string
}

variable "alert_email" {
  description = "Email endpoint subscribed to the alerts topic (empty = no subscription)"
  type        = string
  default     = ""
}
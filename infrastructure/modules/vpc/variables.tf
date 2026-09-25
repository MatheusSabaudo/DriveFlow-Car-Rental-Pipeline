variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two MWAA private subnets. Must fit inside the default VPC (172.31.0.0/16) and not collide with the existing default subnets."
  type        = list(string)
  default     = ["172.31.128.0/20", "172.31.144.0/20"]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two CIDR blocks (MWAA needs two private subnets in two AZs)."
  }
}

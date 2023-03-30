variable "vpc_id" {
  type        = string
  description = "The VPC ID."
  default     = "vpc-1234567890"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnet IDs."
  default     = ["subnet-1234567890", "subnet-1234567890", "subnet-1234567890"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs."
  default     = ["subnet-1234567890", "subnet-1234567890", "subnet-1234567890"]
}

variable "availability_zones" {
  type        = list(string)
  description = "The Availability Zones of eu-central-1."
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "redshift_admin_username" {
  type        = string
  description = "The admin username of the Redshift database."
}

variable "redshift_admin_user_password" {
  type        = string
  description = "The admin password of the Redshift database."
}

variable "redshift_table_name" {
  type        = string
  description = "The table name of the Redshift database."
  default     = "data-warehouse-table"
}

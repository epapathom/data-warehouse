variable "vpc_id" {
  type        = string
  description = "The VPC ID."
  default     = "vpc-0ae5f6061f82a7fad"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnet IDs."
  default     = ["subnet-00b1d42e1a405dcf8", "subnet-0f67031eddbb95811", "subnet-08bf4bc8d5c98385e"]
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs."
  default     = ["subnet-07d46cb7d9b0a75a7", "subnet-00c11094a798d0890", "subnet-007e3361b21f623a5"]
}

variable "availability_zones" {
  type        = list(string)
  description = "The Availability Zones of eu-central-1."
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "ecr_image" {
  type        = string
  description = "The ecs-project ECR image."
  default     = "1234567890.dkr.ecr.eu-central-1.amazonaws.com/ecs-project:latest"
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

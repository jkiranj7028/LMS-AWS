variable "project_name" {
  type        = string
  description = "Name prefix for resources"
  default     = "moodle-lms"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.20.10.0/24", "10.20.11.0/24"]
}

variable "db_username" {
  type        = string
  default     = "moodle"
}

variable "db_password" {
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.medium"
}

variable "db_engine_version" {
  type        = string
  default     = "8.0"
}

variable "s3_bucket_name" {
  type        = string
  default     = null
  description = "If null, one will be generated"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Optional Route53 hosted zone domain, e.g., lms.example.com"
}

variable "enable_cloudfront" {
  type        = bool
  default     = false
}

variable "asg_min" { default = 1 }
variable "asg_max" { default = 3 }
variable "asg_desired" { default = 1 }

variable "instance_type" { default = "t3.large" }

variable "enable_redis" {
  type        = bool
  default     = false
}

# --- Common Project Variables ---
variable "project_name" {
  description = "Name prefix for all banking resources"
  type        = string
  default     = "niloomid-banking"
}

variable "environment" {
  description = "Deployment environment (dev, prod, staging)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-2"
}

# --- Network Configuration ---
variable "vpc_id" {
  description = "Target VPC for EKS and Spark workers"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnets for high-availability EKS deployment"
  type        = list(string)
}

# --- Snowflake Credentials ---
# Mark as sensitive so they never show up in your GitHub Actions logs
variable "snowflake_account" {
  type      = string
  sensitive = true
}

variable "snowflake_user" {
  type      = string
  sensitive = true
}

variable "snowflake_password" {
  type      = string
  sensitive = true
}

# --- Compute Sizing ---
variable "eks_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "snowflake_warehouse_size" {
  description = "Sizing for the ETL warehouse (XSMALL, SMALL, etc.)"
  type        = string
  default     = "XSMALL"
}

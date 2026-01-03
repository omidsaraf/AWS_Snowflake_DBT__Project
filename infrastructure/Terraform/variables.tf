# --- Cloud Infrastructure ---
variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project_name" {
  type    = string
  default = "niloomid-banking"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

# --- Snowflake Credentials (Passed via Env Vars or .tfvars) ---
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

# --- EKS Configuration ---
variable "instance_types" {
  type    = list(string)
  default = ["t3.large"]
}

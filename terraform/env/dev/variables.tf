variable "project_name" { type = string; default = "niloomid-banking" }
variable "environment"  { type = string }
variable "aws_region"   { type = string; default = "ap-southeast-2" }

variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }

variable "eks_instance_types"       { type = list(string); default = ["t3.medium"] }
variable "snowflake_warehouse_size" { type = string; default = "XSMALL" }

variable "snowflake_account"  { type = string; sensitive = true }
variable "snowflake_user"     { type = string; sensitive = true }
variable "snowflake_password" { type = string; sensitive = true }

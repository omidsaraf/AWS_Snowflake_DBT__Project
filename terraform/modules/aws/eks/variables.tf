variable "project_name"     { type = string }
variable "environment"      { type = string }
variable "vpc_id"           { type = string }
variable "subnet_ids"       { type = list(string) }
variable "instance_types"   { type = list(string) }
variable "desired_capacity" { type = number default = 2 }
variable "max_capacity"     { type = number default = 4 }
variable "min_capacity"     { type = number default = 2 }

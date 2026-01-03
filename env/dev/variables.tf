variable "vpc_id" {
  default = "vpc-dev-12345"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-dev-a", "subnet-dev-b"]
}

variable "eks_instance_type" {
  default = "t3.medium" # Cheaper for Dev
}

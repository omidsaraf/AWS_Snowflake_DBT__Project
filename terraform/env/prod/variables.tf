variable "vpc_id" {
  default = "vpc-prod-67890"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-prod-a", "subnet-prod-b"]
}

variable "eks_instance_type" {
  default = "t3.large" # Powerful for Prod
}

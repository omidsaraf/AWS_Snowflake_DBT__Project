# backend.tf
terraform {
  backend "s3" {
    bucket         = "niloomid-terraform-state"
    key            = "banking-platform/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

terraform {
  backend "s3" {
    bucket         = "niloomid-terraform-state"
    key            = "dev/terraform.tfstate" # Isolated path
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.92.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  account  = var.snowflake_account
  user     = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}

module "s3" {
  source = "../../modules/s3"
  
  environment = var.environment
  project_name = var.project_name
}

module "snowflake" {
  source = "../../modules/snowflake"
  
  environment = var.environment
  database_name = var.snowflake_database
}

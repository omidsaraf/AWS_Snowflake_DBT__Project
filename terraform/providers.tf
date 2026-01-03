terraform {
  required_version = ">= 1.5.0"

  # Locking versions prevents "Breaking Changes" from crashing your pipeline
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Allows minor updates but locks major version 5
    }
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.87" # Critical: Snowflake provider updates frequently
    }
  }
}

# Default AWS Provider configuration
provider "aws" {
  region = var.aws_region
}

# Snowflake Provider - Values are passed via variables or env vars
provider "snowflake" {
  account  = var.snowflake_account
  user     = var.snowflake_user
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}

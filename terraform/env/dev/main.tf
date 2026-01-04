terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.92.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

provider "snowflake" {
  account  = var.snowflake_account
  user     = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}

# S3 Buckets
module "s3_raw_data" {
  source = "../../modules/aws/s3"
  
  bucket_name = "${var.project_name}-raw-data-${var.environment}"
  environment = var.environment
  
  lifecycle_rules = [
    {
      id      = "archive_old_data"
      enabled = true
      
      transition = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}

module "s3_processed_data" {
  source = "../../modules/aws/s3"
  
  bucket_name = "${var.project_name}-processed-${var.environment}"
  environment = var.environment
  
  versioning_enabled = true
}

# Snowflake Resources
module "snowflake_database" {
  source = "../../modules/snowflake/database"
  
  database_name          = "ANALYTICS_DB_${upper(var.environment)}"
  environment            = var.environment
  data_retention_days    = 7
  s3_bucket_name         = module.s3_processed_data.bucket_name
  storage_integration_name = snowflake_storage_integration.s3_integration.name
}

# Snowflake Storage Integration
resource "snowflake_storage_integration" "s3_integration" {
  name    = "S3_INTEGRATION_${upper(var.environment)}"
  type    = "EXTERNAL_STAGE"
  enabled = true
  
  storage_allowed_locations = [
    "s3://${module.s3_raw_data.bucket_name}/",
    "s3://${module.s3_processed_data.bucket_name}/"
  ]
  
  storage_provider         = "S3"
  storage_aws_role_arn     = aws_iam_role.snowflake_role.arn
  storage_aws_external_id  = "snowflake_external_id"
}

# IAM Role for Snowflake
resource "aws_iam_role" "snowflake_role" {
  name = "${var.project_name}-snowflake-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.snowflake_aws_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "snowflake_external_id"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "snowflake_s3_access" {
  name = "snowflake-s3-access"
  role = aws_iam_role.snowflake_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          module.s3_raw_data.bucket_arn,
          "${module.s3_raw_data.bucket_arn}/*",
          module.s3_processed_data.bucket_arn,
          "${module.s3_processed_data.bucket_arn}/*"
        ]
      }
    ]
  })
}

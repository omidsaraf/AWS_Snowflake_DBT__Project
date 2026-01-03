# Standard AWS Provider
provider "aws" {
  region = var.aws_region
}

# Snowflake Provider - Required for the snowflake resources to work
provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_user
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}

# --- S3 STORAGE LAYER ---
resource "aws_s3_bucket" "data_lake" {
  for_each = toset(["bronze", "silver", "logs"])
  bucket   = "${var.project_name}-${each.key}"
}

# Add Encryption and Versioning to all buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "lake_encryption" {
  for_each = aws_s3_bucket.data_lake
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- COMPUTE LAYER (EKS) ---
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.15.0"
  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.27"
  
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  eks_managed_node_groups = {
    # High-availability group for Airflow/Core apps
    core = {
      min_size     = 2
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.large"]
    }
  }
}

# --- DATA WAREHOUSE (SNOWFLAKE) ---
resource "snowflake_database" "raw" {
  name    = "RAW_BANKING"
  comment = "Landing zone for Bronze data"
}

resource "snowflake_warehouse" "compute" {
  name           = "ETL_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60 # Save money: drop from 300 to 60 seconds
  auto_resume    = true
}

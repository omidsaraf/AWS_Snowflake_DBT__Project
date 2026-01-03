provider "aws" {
  region = var.aws_region
}

# S3 Buckets
resource "aws_s3_bucket" "bronze" {
  bucket = "${var.project_name}-bronze"
  acl    = "private"
}

resource "aws_s3_bucket" "silver" {
  bucket = "${var.project_name}-silver"
  acl    = "private"
}

resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-logs"
  acl    = "private"
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.27"
  subnets         = var.subnet_ids
  vpc_id          = var.vpc_id
  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 2
      instance_type    = "t3.medium"
    }
  }
}

# Snowflake (placeholder)
resource "snowflake_database" "raw" {
  name = "RAW_BANKING"
}

resource "snowflake_warehouse" "compute" {
  name     = "ETL_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 300
  auto_resume    = true
}

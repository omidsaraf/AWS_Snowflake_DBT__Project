# --- AWS S3 Outputs ---
output "dev_s3_bronze_bucket" {
  description = "The S3 bucket for Bronze/Raw data ingestion"
  value       = module.s3.bronze_bucket_id
}

output "dev_s3_silver_bucket" {
  description = "The S3 bucket for Silver/Cleaned data"
  value       = module.s3.silver_bucket_id
}

# --- AWS EKS Outputs ---
output "dev_eks_cluster_name" {
  description = "The name of the EKS cluster for kubectl context"
  value       = module.eks.cluster_id
}

output "dev_eks_endpoint" {
  description = "The API endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

# Quality of Life: Copy-paste command to connect your local terminal
output "dev_kubectl_config_command" {
  description = "Run this to configure your local kubectl for the Dev environment"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

# --- Snowflake Outputs ---
output "dev_snowflake_database" {
  description = "The Snowflake database name for the Dev environment"
  value       = module.snowflake.database_name
}

output "dev_snowflake_warehouse" {
  description = "The Snowflake warehouse name for Dev ETL"
  value       = module.snowflake.warehouse_name
}

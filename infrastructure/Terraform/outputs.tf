# EKS Connection Details
output "eks_cluster_id" {
  description = "The name/id of the EKS cluster for Kubeconfig context"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API"
  value       = module.eks.cluster_endpoint
}

# S3 Bucket Details (Reflecting the for_each loop)
output "s3_buckets" {
  description = "Map of S3 bucket IDs for Bronze, Silver, and Logs"
  value       = { for k, v in aws_s3_bucket.data_lake : k => v.id }
}

# Snowflake Metadata
output "snowflake_database" {
  description = "The name of the landing database in Snowflake"
  value       = snowflake_database.raw.name
}

output "snowflake_warehouse" {
  description = "The warehouse name for dbt/Spark to use"
  value       = snowflake_warehouse.compute.name
}

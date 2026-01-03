output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "s3_bronze_bucket" {
  value = aws_s3_bucket.bronze.id
}

output "s3_silver_bucket" {
  value = aws_s3_bucket.silver.id
}

output "snowflake_database" {
  value = snowflake_database.raw.name
}

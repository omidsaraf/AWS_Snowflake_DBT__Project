output "s3_bronze_bucket" {
  description = "Bronze bucket for Spark ingestion"
  value       = module.s3.bronze_bucket_id  # Catching from the module
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "bronze_bucket_id" {
  description = "The ID of the Bronze S3 bucket"
  value       = aws_s3_bucket.this["bronze"].id
}

output "silver_bucket_id" {
  description = "The ID of the Silver S3 bucket"
  value       = aws_s3_bucket.this["silver"].id
}

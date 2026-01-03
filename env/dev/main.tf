# env/dev/main.tf
module "banking_platform" {
  source       = "../../modules/infrastructure"
  
  project_name = "niloomid-banking-dev"
  aws_region   = "ap-southeast-2"
  
  # Smaller instances for Dev to save costs
  instance_types = ["t3.medium"]
  
  # Pass other required variables
  vpc_id     = "vpc-12345"
  subnet_ids = ["subnet-abc", "subnet-def"]
}

module "infrastructure" {
  source = "../../modules" # Pointing up to your shared logic

  project_name   = "niloomid-banking-dev"
  instance_types = [var.eks_instance_type]
  vpc_id         = var.vpc_id
  subnet_ids     = var.subnet_ids

  # Development Database Settings
  snowflake_warehouse_size = "XSMALL"
}

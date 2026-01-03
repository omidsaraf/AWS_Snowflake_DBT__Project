module "infrastructure" {
  source = "../../modules"

  project_name   = "niloomid-banking-prod"
  instance_types = [var.eks_instance_type]
  vpc_id         = var.vpc_id
  subnet_ids     = var.subnet_ids

  # Production Database Settings
  snowflake_warehouse_size = "SMALL"
}

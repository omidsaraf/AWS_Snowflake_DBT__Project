module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "${var.project_name}-eks-${var.environment}"
  cluster_version = "1.27"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    general = {
      desired_size = var.desired_capacity
      max_size     = var.max_capacity
      min_size     = var.min_capacity

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }
}

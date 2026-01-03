# Project Identity
project_name = "niloomid-banking"
environment  = "prod"
aws_region   = "ap-southeast-2"

# Network (Isolated Production VPC)
vpc_id     = "vpc-0f99e8e448prod567"
subnet_ids = ["subnet-0444prod", "subnet-0555prod"]

# Compute Sizing (Scaling up for volume)
eks_instance_types       = ["t3.large"]
snowflake_warehouse_size = "SMALL"

# Snowflake Identity
snowflake_account  = "xy12345.ap-southeast-2"
snowflake_user     = "DB_ADMIN_PROD"
# snowflake_password is provided via environment variable for security

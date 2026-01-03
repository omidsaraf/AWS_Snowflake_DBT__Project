# Project Identity
project_name = "niloomid-banking"
environment  = "dev"
aws_region   = "ap-southeast-2"

# Network (Using your specific Dev VPC/Subnets)
vpc_id     = "vpc-0d55e2e137dev1234"
subnet_ids = ["subnet-0816abc", "subnet-0917def"]

# Compute Sizing (Smaller to save costs)
eks_instance_types       = ["t3.medium"]
snowflake_warehouse_size = "XSMALL"

# Snowflake Identity
snowflake_account  = "xy12345.ap-southeast-2"
snowflake_user     = "DB_ADMIN_DEV"
# snowflake_password is provided via environment variable for security

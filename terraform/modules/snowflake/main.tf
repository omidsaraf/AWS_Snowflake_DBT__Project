resource "snowflake_database" "this" {
  name    = "RAW_${upper(var.environment)}"
  comment = "Database for the ${var.environment} environment"
}

resource "snowflake_warehouse" "this" {
  name           = "COMPUTE_WH_${upper(var.environment)}"
  warehouse_size = var.warehouse_size
  auto_suspend   = 60
  auto_resume    = true
}

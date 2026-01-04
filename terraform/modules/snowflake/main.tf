terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.92.0"
    }
  }
}

# Create Database
resource "snowflake_database" "analytics" {
  name                        = var.database_name
  comment                     = "Banking Analytics Database - ${var.environment}"
  data_retention_time_in_days = var.data_retention_days
}

# Create Schemas
resource "snowflake_schema" "raw" {
  database = snowflake_database.analytics.name
  name     = "RAW"
  comment  = "Raw data from S3"
}

resource "snowflake_schema" "staging" {
  database = snowflake_database.analytics.name
  name     = "STAGING"
  comment  = "Staging layer for dbt"
}

resource "snowflake_schema" "vault" {
  database = snowflake_database.analytics.name
  name     = "VAULT"
  comment  = "Data Vault 2.0 structures"
}

resource "snowflake_schema" "marts" {
  database = snowflake_database.analytics.name
  name     = "MARTS"
  comment  = "Business marts"
}

# Create File Format for Parquet
resource "snowflake_file_format" "parquet_format" {
  name             = "PARQUET_FORMAT"
  database         = snowflake_database.analytics.name
  schema           = snowflake_schema.raw.name
  format_type      = "PARQUET"
  compression      = "SNAPPY"
  binary_as_text   = false
  trim_space       = true
}

# Create External Stage for S3
resource "snowflake_stage" "s3_stage" {
  name     = "BANKING_STAGE"
  database = snowflake_database.analytics.name
  schema   = snowflake_schema.raw.name
  url      = "s3://${var.s3_bucket_name}/processed/"
  
  storage_integration = var.storage_integration_name
  
  file_format = "FORMAT_NAME = ${snowflake_file_format.parquet_format.name}"
  
  comment = "S3 external stage for banking data"
}

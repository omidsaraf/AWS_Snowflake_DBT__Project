from utils.spark_utils import create_spark_session, read_from_s3, write_to_s3
from pyspark.sql.functions import col, upper, concat_ws
import logging
import sys

def main():
    spark = create_spark_session("Silver Transformation")
    
    try:
        # Read Bronze data
        customer_df = read_from_s3(spark, "s3a://bronze-bucket/customers/")
        account_df = read_from_s3(spark, "s3a://bronze-bucket/accounts/")
        
        # Example transformation: clean nulls, standardize text, enrich
        customer_df = (
            customer_df
            .withColumn("first_name", upper(col("first_name")))
            .withColumn("last_name", upper(col("last_name")))
            .withColumn("full_name", concat_ws(" ", col("first_name"), col("last_name")))
        )
        
        account_df = account_df.dropna(subset=["account_id"])
        
        # Write to Silver Layer
        write_to_s3(customer_df, "s3a://silver-bucket/customers/")
        write_to_s3(account_df, "s3a://silver-bucket/accounts/")
        
        logging.info("Silver transformation completed successfully")
    except Exception as e:
        logging.error(f"Silver transformation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
## Cleaned & Enriched Silver Layer
## Transforms raw Bronze data into clean Silver tables, adds derived columns, removes nulls, and standardizes names.

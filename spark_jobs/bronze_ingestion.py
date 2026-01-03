from pyspark.sql import SparkSession
from pyspark.sql.functions import col
import logging

def create_spark_session(app_name="NILOOMID Banking ETL"):
    spark = (
        SparkSession.builder
        .appName(app_name)
        .config("spark.sql.shuffle.partitions", "200")
        .config("spark.driver.memory", "4g")
        .config("spark.executor.memory", "4g")
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("INFO")
    logging.info("Spark Session created")
    return spark

def read_from_s3(spark, path, format="parquet"):
    logging.info(f"Reading data from S3 path: {path}")
    return spark.read.format(format).load(path)

def write_to_s3(df, path, format="parquet", mode="overwrite"):
    logging.info(f"Writing data to S3 path: {path}, format: {format}, mode: {mode}")
    df.write.format(format).mode(mode).save(path)
## Utility Functions

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.transfers.s3_to_snowflake import S3ToSnowflakeOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.python import PythonOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['data-team@company.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'banking_data_ingestion',
    default_args=default_args,
    description='Ingest banking data from S3 to Snowflake',
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    catchup=False,
    tags=['banking', 'ingestion'],
) as dag:

    # Task 1: Spark job to process raw files in S3
    spark_process_raw = SparkSubmitOperator(
        task_id='spark_process_raw_data',
        application='/opt/airflow/spark_jobs/bronze_ingestion.py',
        conn_id='spark_default',
        conf={
            'spark.executor.memory': '4g',
            'spark.driver.memory': '2g',
            'spark.executor.cores': '2',
        },
        application_args=[
            '--source-path', 's3://banking-raw/{{ ds }}/',
            '--target-path', 's3://banking-processed/{{ ds }}/',
        ],
    )

    # Task 2: Load to Snowflake
    load_customers = S3ToSnowflakeOperator(
        task_id='load_customers_to_snowflake',
        snowflake_conn_id='snowflake_default',
        s3_keys=['s3://banking-processed/{{ ds }}/customers.parquet'],
        table='RAW.BANKING.CUSTOMERS',
        schema='BANKING',
        stage='BANKING_STAGE',
        file_format='PARQUET_FORMAT',
    )

    # Task 3: Run data quality checks
    quality_check = SnowflakeOperator(
        task_id='run_quality_checks',
        snowflake_conn_id='snowflake_default',
        sql="""
            SELECT 
                COUNT(*) as record_count,
                COUNT(DISTINCT customer_id) as unique_customers
            FROM RAW.BANKING.CUSTOMERS
            WHERE load_date = '{{ ds }}';
        """,
    )

    # Task dependencies
    spark_process_raw >> load_customers >> quality_check

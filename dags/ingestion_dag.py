"""
S3 to Snowflake Ingestion DAG
Ingests raw banking data from S3 to Snowflake RAW layer
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.transfers.s3_to_snowflake import S3ToSnowflakeOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.utils.task_group import TaskGroup
from airflow.sensors.external_task import ExternalTaskSensor

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['data-team@company.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
    'max_retry_delay': timedelta(minutes=30),
}

with DAG(
    dag_id='s3_to_snowflake_ingest',
    default_args=default_args,
    description='Batch ingestion from S3 to Snowflake',
    schedule_interval='0 2 * * *',  # 2 AM daily
    catchup=False,
    max_active_runs=1,
    tags=['ingestion', 'banking', 's3', 'snowflake'],
    doc_md=__doc__,
) as dag:

    # Task 1: Spark Bronze Layer Processing
    spark_bronze_processing = SparkSubmitOperator(
        task_id='spark_bronze_processing',
        application='/opt/airflow/spark_jobs/bronze_ingestion.py',
        conn_id='spark_default',
        name='banking_bronze_ingest_{{ ds }}',
        conf={
            'spark.executor.memory': '4g',
            'spark.driver.memory': '2g',
            'spark.executor.cores': '2',
            'spark.executor.instances': '3',
            'spark.sql.adaptive.enabled': 'true',
        },
        application_args=[
            '--source-bucket', 's3://banking-raw-data',
            '--source-prefix', 'banking/{{ ds }}/',
            '--target-bucket', 's3://banking-processed',
            '--target-prefix', 'bronze/{{ ds }}/',
            '--execution-date', '{{ ds }}',
        ],
        verbose=True,
    )

    # Task Group: Load to Snowflake RAW Layer
    with TaskGroup('load_to_snowflake', tooltip='Load processed data to Snowflake') as load_group:
        
        load_customers = S3ToSnowflakeOperator(
            task_id='load_customers',
            snowflake_conn_id='snowflake_default',
            s3_keys=['s3://banking-processed/bronze/{{ ds }}/customers/'],
            table='RAW_DB.BANKING.RAW_CUSTOMERS',
            stage='BANKING_STAGE',
            file_format='(TYPE=PARQUET)',
            copy_options=['MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE'],
        )

        load_accounts = S3ToSnowflakeOperator(
            task_id='load_accounts',
            snowflake_conn_id='snowflake_default',
            s3_keys=['s3://banking-processed/bronze/{{ ds }}/accounts/'],
            table='RAW_DB.BANKING.RAW_ACCOUNTS',
            stage='BANKING_STAGE',
            file_format='(TYPE=PARQUET)',
            copy_options=['MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE'],
        )

        load_transactions = S3ToSnowflakeOperator(
            task_id='load_transactions',
            snowflake_conn_id='snowflake_default',
            s3_keys=['s3://banking-processed/bronze/{{ ds }}/transactions/'],
            table='RAW_DB.BANKING.RAW_TRANSACTIONS',
            stage='BANKING_STAGE',
            file_format='(TYPE=PARQUET)',
            copy_options=['MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE'],
        )

    # Task 3: Data Quality Checks
    with TaskGroup('data_quality_checks', tooltip='Validate loaded data') as quality_group:
        
        check_customers = SnowflakeOperator(
            task_id='check_customers_count',
            snowflake_conn_id='snowflake_default',
            sql="""
                SELECT 
                    COUNT(*) as row_count,
                    COUNT(DISTINCT customer_id) as unique_customers,
                    COUNT(*) - COUNT(customer_id) as null_keys
                FROM RAW_DB.BANKING.RAW_CUSTOMERS
                WHERE _loaded_at::DATE = '{{ ds }}';
            """,
        )

        check_accounts = SnowflakeOperator(
            task_id='check_accounts_referential_integrity',
            snowflake_conn_id='snowflake_default',
            sql="""
                SELECT COUNT(*) as orphaned_accounts
                FROM RAW_DB.BANKING.RAW_ACCOUNTS a
                LEFT JOIN RAW_DB.BANKING.RAW_CUSTOMERS c ON a.customer_id = c.customer_id
                WHERE a._loaded_at::DATE = '{{ ds }}'
                AND c.customer_id IS NULL;
            """,
        )

    # Task 4: Send completion notification
    def send_completion_notification(**context):
        """Log completion metrics"""
        import logging
        logging.info(f"Ingestion completed for {context['ds']}")
        return f"SUCCESS: Data loaded for {context['ds']}"

    notify_completion = PythonOperator(
        task_id='notify_completion',
        python_callable=send_completion_notification,
        provide_context=True,
    )

    # Define task dependencies
    spark_bronze_processing >> load_group >> quality_group >> notify_completion

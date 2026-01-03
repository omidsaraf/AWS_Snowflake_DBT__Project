## Bronze Layer / Raw Ingestion

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

with DAG(
    dag_id='bronze_ingestion_dag',
    default_args=default_args,
    description='Ingest raw banking data into Bronze Layer',
    schedule_interval='@daily',
    start_date=days_ago(1),
    catchup=False,
    tags=['banking', 'ingestion', 'spark']
) as dag:

    bronze_ingestion = KubernetesPodOperator(
        namespace='default',
        image='yourdockerhub/spark:latest',
        cmds=["spark-submit", "--master", "k8s://https://kubernetes.default.svc", "/opt/spark_jobs/bronze_ingestion.py"],
        name='bronze-ingestion-job',
        task_id='bronze_ingestion_task',
        get_logs=True,
        is_delete_operator_pod=True
    )

    bronze_ingestion

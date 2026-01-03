## Data Vault Layer / Hub, Link, Satellite
### This DAG orchestrates dbt transformations for Data Vault hubs, links, satellites in Snowflake, followed by automated dbt tests to ensure data quality.
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
    dag_id='dbt_datavault_dag',
    default_args=default_args,
    description='Load Data Vault 2.0 models into Snowflake',
    schedule_interval='@daily',
    start_date=days_ago(1),
    catchup=False,
    tags=['banking', 'dbt', 'datavault']
) as dag:

    dbt_run = KubernetesPodOperator(
        namespace='default',
        image='yourdockerhub/dbt:latest',
        cmds=["dbt", "run", "--project-dir", "/opt/dbt"],
        name='dbt-runner-job',
        task_id='dbt_run_task',
        get_logs=True,
        is_delete_operator_pod=True
    )

    dbt_test = KubernetesPodOperator(
        namespace='default',
        image='yourdockerhub/dbt:latest',
        cmds=["dbt", "test", "--project-dir", "/opt/dbt"],
        name='dbt-test-job',
        task_id='dbt_test_task',
        get_logs=True,
        is_delete_operator_pod=True
    )

    dbt_run >> dbt_test


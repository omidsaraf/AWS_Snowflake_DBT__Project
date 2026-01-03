from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
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

    # Task 1: Run Raw Vault (Hubs, Links, Satellites)
    dbt_run = KubernetesPodOperator(
        namespace='default',
        image='yourdockerhub/dbt:latest',
        # Syncing with our previous selector and directory
        cmds=["dbt"],
        arguments=["run", "--project-dir", "/usr/app/dbt", "--selector", "raw_vault_layer"],
        name='dbt-vault-run',
        task_id='dbt_run_task',
        get_logs=True,
        is_delete_operator_pod=True,
        # Pass the profile directory env var
        env_vars={
            'DBT_PROFILES_DIR': '/usr/app/dbt/config'
        }
    )

    # Task 2: Data Quality Tests
    dbt_test = KubernetesPodOperator(
        namespace='default',
        image='yourdockerhub/dbt:latest',
        cmds=["dbt"],
        arguments=["test", "--project-dir", "/usr/app/dbt", "--selector", "raw_vault_layer"],
        name='dbt-vault-test',
        task_id='dbt_test_task',
        get_logs=True,
        is_delete_operator_pod=True,
        env_vars={
            'DBT_PROFILES_DIR': '/usr/app/dbt/config'
        }
    )

    dbt_run >> dbt_test

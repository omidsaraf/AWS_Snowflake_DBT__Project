from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping

# Using Astronomer Cosmos for dbt integration
profile_config = ProfileConfig(
    profile_name="banking_vault",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={
            "database": "ANALYTICS",
            "schema": "VAULT"
        },
    )
)

dbt_project_config = ProjectConfig(
    dbt_project_path="/opt/airflow/dbt",
)

dbt_dag = DbtDag(
    project_config=dbt_project_config,
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path="/usr/local/bin/dbt",
    ),
    schedule_interval="0 4 * * *",  # 4 AM daily
    start_date=datetime(2024, 1, 1),
    catchup=False,
    dag_id="dbt_banking_transformation",
    default_args={
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["dbt", "transformation"],
)

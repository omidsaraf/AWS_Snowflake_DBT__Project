# Use official dbt image
FROM dbt-labs/dbt-snowflake:1.7.0

# Set working directory
WORKDIR /opt/dbt

# Copy dbt project
COPY ../dbt /opt/dbt

# Install any additional Python packages
RUN pip install --no-cache-dir \
    pandas==2.1.0 \
    boto3==1.26.0

# Default command for Airflow DAGs
ENTRYPOINT ["dbt"]


## dbt container ready for Snowflake, integrates with Airflow DAG (dbt_dag.py), and supports modular Data Vault transformations.

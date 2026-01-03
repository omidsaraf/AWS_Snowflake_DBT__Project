# Use official dbt-labs image for consistency
# 1.7.x is a stable choice; ensures compatibility with automate-dv
FROM ghcr.io/dbt-labs/dbt-snowflake:1.7.latest

# Set working directory to standard dbt app path
WORKDIR /usr/app/dbt

# Copy the dbt project folder
# Note: If running 'docker build' from the root of the project, 
# the source path should be 'dbt'
COPY dbt/ .

# Install helper libraries for potential Python-based dbt models or Airflow logic
RUN pip install --no-cache-dir \
    pandas==2.1.0 \
    boto3==1.26.0

# Pre-install dbt dependencies (automate-dv, dbt-utils) 
# to save time during Airflow execution
RUN dbt deps

# Essential for Airflow's KubernetesPodOperator to find your profiles
ENV DBT_PROFILES_DIR=/usr/app/dbt

# Entrypoint is dbt, so Airflow can just pass "run" or "test" as arguments
ENTRYPOINT ["dbt"]

## dbt container ready for Snowflake, integrates with Airflow DAG (dbt_dag.py), and supports modular Data Vault transformations.

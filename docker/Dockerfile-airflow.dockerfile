

FROM apache/airflow:2.8.1-python3.11

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Install Airflow providers
RUN pip install --no-cache-dir \
    apache-airflow-providers-amazon[s3]==8.15.0 \
    apache-airflow-providers-snowflake==5.3.0 \
    apache-airflow-providers-apache-spark==4.6.0 \
    astronomer-cosmos[dbt-snowflake]==1.3.0

# Copy DAGs and dbt project
COPY --chown=airflow:root dags/ ${AIRFLOW_HOME}/dags/
COPY --chown=airflow:root dbt/ ${AIRFLOW_HOME}/dbt/

ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__CORE__DAGS_FOLDER=${AIRFLOW_HOME}/dags

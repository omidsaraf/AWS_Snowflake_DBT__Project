# Use official Airflow image
FROM apache/airflow:2.8.0-python3.11

# Set environment variables
ENV AIRFLOW_HOME=/opt/airflow

# We stay as 'airflow' user to install packages safely
USER airflow

# Install providers and connectors
# Added apache-airflow-providers-cncf-kubernetes so your DAG can talk to K8s!
RUN pip install --no-cache-dir \
    snowflake-connector-python==3.1.2 \
    pandas==2.1.0 \
    boto3==1.26.0 \
    apache-airflow-providers-amazon==6.2.0 \
    apache-airflow-providers-cncf-kubernetes==7.10.0

# Copy DAGs (In K8s, we often use git-sync or a PersistentVolume, 
# but copying into the image is great for CI/CD stability)
COPY --chown=airflow:root ../dags $AIRFLOW_HOME/dags
COPY --chown=airflow:root ../spark_jobs/utils /opt/spark_jobs/utils

# The entrypoint is already set by the base image
EXPOSE 8080

## Airflow container with PySpark, Snowflake, S3 support, ready to run DAGs on K8s.

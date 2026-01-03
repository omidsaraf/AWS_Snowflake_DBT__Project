# Use official Airflow image
FROM apache/airflow:2.8.0-python3.11

# Set environment variables
ENV AIRFLOW_HOME=/opt/airflow

# Install extra Python packages for Spark and Snowflake connectivity
USER root
RUN pip install --no-cache-dir \
    pyspark==3.5.1 \
    snowflake-connector-python==3.1.2 \
    pandas==2.1.0 \
    boto3==1.26.0 \
    apache-airflow-providers-amazon==6.2.0

# Switch back to airflow user
USER airflow

# Copy DAGs and utils
COPY ../dags $AIRFLOW_HOME/dags
COPY ../spark_jobs/utils /opt/spark_jobs/utils

# Expose webserver port
EXPOSE 8080

# Default command
CMD ["webserver"]


## Airflow container with PySpark, Snowflake, S3 support, ready to run DAGs on K8s.

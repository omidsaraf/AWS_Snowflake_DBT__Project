# Use official Spark image
FROM bitnami/spark:3.5.1

# Set Spark home
ENV SPARK_HOME=/opt/bitnami/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Install Python dependencies for banking ETL
USER root
RUN pip install --no-cache-dir \
    boto3==1.26.0 \
    pandas==2.1.0 \
    snowflake-connector-python==3.1.2

# Switch to spark user
USER 1001

# Copy Spark jobs and utils
COPY ../spark_jobs /opt/spark_jobs

WORKDIR /opt/spark_jobs

# Entry point is spark-submit
ENTRYPOINT ["spark-submit"]


## Spark container with S3 and Snowflake connectors for both Bronze and Silver jobs.

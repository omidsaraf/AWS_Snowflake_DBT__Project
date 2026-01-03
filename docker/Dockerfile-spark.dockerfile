# Bitnami is excellent for non-root K8s security standards
FROM bitnami/spark:3.5.1

USER root

# Install Python requirements
RUN pip install --no-cache-dir \
    boto3==1.26.0 \
    pandas==2.1.0 \
    snowflake-connector-python==3.1.2

# Download Snowflake Spark Connectors (Required for Spark to talk to Snowflake)
# We place them in the jars folder so Spark picks them up automatically
ADD https://repo1.maven.org/maven2/net/snowflake/spark-snowflake_2.12/2.12.0-spark_3.4/spark-snowflake_2.12-2.12.0-spark_3.4.jar /opt/bitnami/spark/jars/
ADD https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.14.4/snowflake-jdbc-3.14.4.jar /opt/bitnami/spark/jars/

# Ensure permissions are correct for the spark user
RUN chmod 644 /opt/bitnami/spark/jars/spark-snowflake* /opt/bitnami/spark/jars/snowflake-jdbc*

# Copy your ingestion logic
COPY --chown=1001:1001 ../spark_jobs /opt/spark_jobs

USER 1001
WORKDIR /opt/spark_jobs

ENTRYPOINT ["spark-submit"]

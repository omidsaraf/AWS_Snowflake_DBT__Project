# Standardizing on dbt 1.7.x for automate-dv compatibility
##FROM ghcr.io/dbt-labs/dbt-snowflake:1.7.latest

##WORKDIR /usr/app/dbt

# Copy project files
##COPY dbt/ .

# Install dependencies for Python models or custom hooks
##RUN pip install --no-cache-dir \
##    pandas==2.1.0 \
##    boto3==1.26.0

# Pre-fetch dbt packages (automate-dv, etc.)
##RUN dbt deps

# Set the profiles directory to a dedicated config subfolder
# This matches your K8s mountPath
##ENV DBT_PROFILES_DIR=/usr/app/dbt/config

##ENTRYPOINT ["dbt"]


FROM bitnami/spark:3.5.0

USER root

# Install Python dependencies for Spark jobs
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy Spark jobs
COPY spark_jobs/ /opt/spark/jobs/

USER 1001

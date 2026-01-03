#!/bin/bash
# =============================================================================
# NILOOMID Banking Data Platform - Deployment Script
# =============================================================================
# This script builds Docker images, provisions infrastructure via Terraform,
# and deploys Airflow, Spark, and dbt jobs to Kubernetes.
# =============================================================================

set -e

# -------------------------------
# CONFIGURATION
# -------------------------------
PROJECT_NAME="niloomid-banking"
AWS_REGION="ap-southeast-2"
DOCKER_REGISTRY="yourdockerhub"
K8S_NAMESPACE="default"
TERRAFORM_DIR="../infrastructure/terraform"
K8S_DIR="../infrastructure/k8s"

# -------------------------------
# FUNCTION: Build Docker Images
# -------------------------------
echo "🔹 Building Docker images..."
docker build -t $DOCKER_REGISTRY/airflow:latest ../docker/Dockerfile-airflow
docker build -t $DOCKER_REGISTRY/spark:latest ../docker/Dockerfile-spark
docker build -t $DOCKER_REGISTRY/dbt:latest ../docker/Dockerfile-dbt

echo "✅ Docker images built successfully."

# -------------------------------
# FUNCTION: Terraform Provisioning
# -------------------------------
echo "🔹 Initializing and applying Terraform..."
cd $TERRAFORM_DIR
terraform init
terraform apply -auto-approve \
  -var="aws_region=$AWS_REGION" \
  -var="project_name=$PROJECT_NAME"

echo "✅ Terraform infrastructure deployed."

# -------------------------------
# FUNCTION: Kubernetes Deployment
# -------------------------------
echo "🔹 Deploying Kubernetes manifests..."
cd $K8S_DIR
kubectl apply -f airflow-deployment.yaml -n $K8S_NAMESPACE
kubectl apply -f spark-job.yaml -n $K8S_NAMESPACE
kubectl apply -f dbt-runner.yaml -n $K8S_NAMESPACE

echo "✅ Kubernetes workloads deployed."

# -------------------------------
# FUNCTION: Verify Deployments
# -------------------------------
echo "🔹 Verifying Kubernetes deployments..."
kubectl get pods -n $K8S_NAMESPACE

echo "🚀 NILOOMID Banking Data Platform deployment completed successfully!"


# Full-stack deployment: Docker → Terraform → Kubernetes.
# Automated Docker image builds for Airflow, Spark, dbt.
# Terraform provisioning of S3, EKS, Snowflake resources.
# Kubernetes manifests applied automatically.
# CI/CD ready: can be executed in GitHub Actions, GitLab CI, or Jenkins.
# Error handling with set -e ensures immediate exit on failure.
# Logs & Verification: lists deployed pods for confirmation.

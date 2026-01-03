# Setup Guide

## Prerequisites
- AWS Account with appropriate permissions
- Snowflake account
- Docker Desktop installed
- Python 3.11+
- Terraform 1.5+

## Step-by-Step Setup

### 1. Clone Repository
\`\`\`bash
git clone https://github.com/omidsaraf/AWS_Snowflake_DBT__Project.git
cd AWS_Snowflake_DBT__Project
\`\`\`

### 2. Configure Environment
\`\`\`bash
cp .env.example .env
# Edit .env with your credentials
\`\`\`

### 3. Setup Infrastructure
\`\`\`bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
\`\`\`

### 4. Setup dbt
\`\`\`bash
cd dbt
dbt deps
dbt debug
dbt seed
dbt run
dbt test
\`\`\`

### 5. Start Airflow
\`\`\`bash
docker-compose up -d
# Access UI at http://localhost:8080
# Username: airflow
# Password: airflow
\`\`\`

## Troubleshooting
See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
\`\`\`

### 9. **CI/CD Pipeline**

**Create `.github/workflows/ci.yml`**:
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  dbt-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install dbt-core dbt-snowflake
          cd dbt && dbt deps
      
      - name: Run dbt tests
        run: |
          cd dbt
          dbt compile --profiles-dir .
          dbt test --profiles-dir .
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}

  terraform-validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Format
        run: |
          cd terraform/environments/dev
          terraform fmt -check
      
      - name: Terraform Validate
        run: |
          cd terraform/environments/dev
          terraform init -backend=false
          terraform validate

  docker-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker images
        run: |
          docker build -f docker/airflow.Dockerfile -t airflow:test .
          docker build -f docker/spark.Dockerfile -t spark:test .
```

### 10. **Next Steps Checklist**

- [ ] Remove exposed credentials from git history
- [ ] Create and configure all missing files
- [ ] Set up Terraform remote backend
- [ ] Configure Snowflake warehouses and roles
- [ ] Test dbt models locally
- [ ] Configure Airflow connections
- [ ] Set up monitoring and alerting
- [ ] Document data lineage
- [ ] Create data quality tests
- [ ] Set up CI/CD pipeline
- [ ] Create disaster recovery plan
- [ ] Document security policies

## Priority Actions (Do These First!)

1. **IMMEDIATE**: Remove `.env` file from repository
2. **HIGH**: Create proper `.gitignore`
3. **HIGH**: Create `dbt_project.yml` and proper dbt structure
4. **MEDIUM**: Fix Terraform organization
5. **MEDIUM**: Update Airflow DAGs with proper error handling

## Additional Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Data Vault 2.0 Guide](https://danlinstedt.com/datavault-2-0/)
- [Airflow Best Practices](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Snowflake dbt Package](https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup)

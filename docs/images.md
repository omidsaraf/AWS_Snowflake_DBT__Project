1️⃣ architecture_diagram.png

The high-level end-to-end architecture we generated earlier.

Shows data sources → Bronze → Silver → Data Vault → Analytics.

Includes icons for AWS, Spark, Airflow, dbt, Snowflake, Docker, K8s.

2️⃣ airflow_dag_overview.png

A visual DAG overview showing:

ingestion_dag.py → processing_dag.py → dbt_dag.py

Dependencies and task flow

Useful for onboarding or internal wiki.

3️⃣ dbt_data_vault_flow.png

Illustrates the Data Vault 2.0 flow:

Staging → Hubs → Links → Satellites

Shows hub-customer, link-customer-account, sat-customer-profile relationships.

4️⃣ sample_data_preview.png

Small screenshot of sample CSVs (customers.csv, accounts.csv, transactions.csv)

Helps developers quickly understand column names, types, and relationships.

✅ Notes

Store all documentation images in docs/images/ for easy reference.

GitHub will render them in README.md using relative paths, e.g.:

![Architecture](docs/images/architecture_diagram.png)


Keeps project repo organized, separating code, data, and documentation.

You can expand with ER diagrams, example dashboards, or pipeline monitoring screenshots.

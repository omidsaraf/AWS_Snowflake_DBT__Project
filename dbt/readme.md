Fully Data Vault 2.0 compliant: Hubs, Links, Satellites.

Staging layer separates raw Bronze data from the Vault.

Snowflake-ready materializations: views for staging, tables for hubs/links/sats.

Can be orchestrated via Airflow DAG (dbt_dag.py).

Easy to extend for other domains: accounts, transactions, loans, cards, etc.



dbt/
├── models/
│   ├── staging/      # Layer 1: Data cleaning, casting, and hashing keys
│   ├── vault/        # Layer 2: Core Audit (Hubs, Links, Satellites)
│   │   ├── hubs/     # Unique Business Keys
│   │   ├── links/    # Relationships (N:N)
│   │   └── satellites/# Descriptive data over time (SCD Type 2)
│   └── marts/        # Layer 3: Reporting layer for BI (Star Schema)
├── macros/           # Custom logic for PII masking or vault hashing
├── dbt_project.yml   # Core project orchestration
└── packages.yml      # External libraries (e.g., automate-dv)

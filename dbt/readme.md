Fully Data Vault 2.0 compliant: Hubs, Links, Satellites.

Staging layer separates raw Bronze data from the Vault.

Snowflake-ready materializations: views for staging, tables for hubs/links/sats.

Can be orchestrated via Airflow DAG (dbt_dag.py).

Easy to extend for other domains: accounts, transactions, loans, cards, etc.


```Plaintext
dbt/
├── models/
│   ├── staging/               # LAYER 1: Standardizing & Hashing
│   │   ├── _sources.yml       # <--- MAPS RAW SNOWFLAKE TABLES
│   │   ├── stg_accounts.sql
│   │   ├── stg_customer.sql
│   │   └── stg_transactions.sql
│   │
│   ├── vault/                 # LAYER 2: The Auditable Core
│   │   ├── hubs/              # Unique Business Keys (Who/What)
│   │   │   ├── hub_account.sql
│   │   │   └── hub_customer.sql
│   │   ├── links/             # Relationships (Associations)
│   │   │   └── link_customer_account.sql
│   │   └── satellites/        # Descriptive Context (History)
│   │       ├── sat_customer_profile.sql
│   │       └── sat_account_balance.sql
│   │
│   └── marts/                 # LAYER 3: Reporting (Gold Layer)
│       ├── _marts.yml
│       └── mart_customer_360.sql
│
├── macros/                    # Custom Hashing or Masking logic
├── tests/                     # Data Quality (e.g., check for negative balances)
├── dbt_project.yml            # Core Orchestration & Materialization
├── packages.yml               # External Engines (automate-dv)
└── selectors.yml              # (Optional) For running specific layers

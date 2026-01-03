Fully Data Vault 2.0 compliant: Hubs, Links, Satellites.

Staging layer separates raw Bronze data from the Vault.

Snowflake-ready materializations: views for staging, tables for hubs/links/sats.

Can be orchestrated via Airflow DAG (dbt_dag.py).

Easy to extend for other domains: accounts, transactions, loans, cards, etc.


```Plaintext
niloomid_banking_dv/ (Root)
├── .gitignore                   # Added: Security for credentials/logs
├── README.md                    # Added: Project documentation
├── dbt_project.yml              # Central configuration
├── packages.yml                 # Automate-DV dependency
├── selectors.yml                # Layer execution logic
├── profiles.yml                 # (Keep locally, do NOT upload to GitHub)
├── models/
│   ├── staging/                 # Layer 1: Hashing & Cleaning
│   │   ├── _sources.yml
│   │   ├── stg_banking_accounts.sql
│   │   ├── stg_customer.sql
│   │   └── stg_transactions.sql
│   ├── vault/                   # Layer 2: Raw Vault (Auditable)
│   │   ├── hubs/
│   │   │   ├── hub_account.sql
│   │   │   └── hub_customer.sql
│   │   ├── links/
│   │   │   ├── link_customer_account.sql
│   │   │   └── t_link_transactions.sql
│   │   └── satellites/
│   │       ├── sat_customer_profile.sql
│   │       └── sat_account_balance.sql
│   └── marts/                   # Layer 3: Information Marts (Gold)
│       ├── _marts.yml
│       └── mart_customer_360.sql
├── macros/                      # Custom logic
└── tests/                       # Data quality tests

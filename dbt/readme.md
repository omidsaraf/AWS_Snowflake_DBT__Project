Fully Data Vault 2.0 compliant: Hubs, Links, Satellites.

Staging layer separates raw Bronze data from the Vault.

Snowflake-ready materializations: views for staging, tables for hubs/links/sats.

Can be orchestrated via Airflow DAG (dbt_dag.py).

Easy to extend for other domains: accounts, transactions, loans, cards, etc.


```Plaintext
dbt/
├── models/
│   ├── staging/
│   │   ├── _sources.yml             # Maps RAW_DB.LANDING tables
│   │   ├── stg_banking_accounts.sql # Parent for Hub_Account & Sat_Account
│   │   ├── stg_customer.sql         # Parent for Hub_Customer & Sat_Customer
│   │   └── stg_transactions.sql     # Parent for T_Link_Transactions
│   │
│   ├── vault/
│   │   ├── hubs/
│   │   │   ├── hub_account.sql
│   │   │   └── hub_customer.sql
│   │   ├── links/
│   │   │   ├── link_customer_account.sql
│   │   │   └── t_link_transactions.sql # <--- ADDED: Transactional Link
│   │   └── satellites/
│   │       ├── sat_customer_profile.sql
│   │       └── sat_account_balance.sql
│   │
│   └── marts/
│       ├── _marts.yml
│       └── mart_customer_360.sql    # Joins Hubs, Links, & latest Sat records
│
├── macros/                          # automate-dv macros & custom masking
├── tests/                           # Business logic tests (e.g. balance > 0)
├── dbt_project.yml                  # Configures +materialized: incremental
├── packages.yml                     # Includes automate_dv & dbt_utils
└── selectors.yml

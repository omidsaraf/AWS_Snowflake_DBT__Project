Fully Data Vault 2.0 compliant: Hubs, Links, Satellites.

Staging layer separates raw Bronze data from the Vault.

Snowflake-ready materializations: views for staging, tables for hubs/links/sats.

Can be orchestrated via Airflow DAG (dbt_dag.py).

Easy to extend for other domains: accounts, transactions, loans, cards, etc.

-- dbt/models/vault/satellites/sat_account_balance.sql
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_banking_accounts'
src_pk: 'ACCOUNT_HK'              -- Links back to the Account Hub
src_hashdiff: 'ACCOUNT_HASHDIFF'  -- Detects if balance or type changed
src_payload:                       -- The attributes we want to track
  - 'account_type'
  - 'balance'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata['src_pk'],
                   src_hashdiff=metadata['src_hashdiff'],
                   src_payload=metadata['src_payload'],
                   src_ldts=metadata['src_ldts'],
                   src_source=metadata['src_source'],
                   source_model=metadata['source_model']) }}


-- Historical Accuracy: If a customer’s balance was $1,500.50 on January 15th and changed to $2,000.00 on February 1st, this table will hold both records. You can go back in time to see exactly what the balance was at any moment.

-- Storage Efficiency: If the balance doesn't change for six months, the src_hashdiff logic prevents dbt from inserting duplicate rows every day, keeping your Snowflake storage lean.

-- Regulatory Compliance: Banks are often required to show "Point-in-Time" states. This Satellite allows you to recreate the state of any account for any specific date for auditors.

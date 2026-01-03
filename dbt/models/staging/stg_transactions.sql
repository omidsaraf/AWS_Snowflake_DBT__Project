-- dbt/models/staging/stg_transactions.sql
{%- set yaml_metadata -%}
source_model: 'raw_transactions'
derived_columns:
  RECORD_SOURCE: '!S3_CORE_BANKING'
  LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
hashed_columns:
  # The Primary Key for the Transaction itself
  TRANSACTION_HK: 'transaction_id'
  
  # The Foreign Key to the Account Hub
  ACCOUNT_HK: 'account_id'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata['source_model'],
                     derived_columns=metadata['derived_columns'],
                     hashed_columns=metadata['hashed_columns']) }}


-- Transactional Integrity: By hashing the transaction_id, you create a deterministic key. If the same transaction file is accidentally loaded twice, your downstream Hubs and Links will automatically ignore the duplicates.

-- No HashDiff needed: Unlike stg_banking_accounts.sql, we do not create a HASHDIFF here. In banking, you don't track "changes" to a transaction; you simply store the record as it arrived.

-- Audit Trail: The RECORD_SOURCE ensures that if an auditor asks which specific system or S3 bucket a withdrawal came from, that metadata is baked into the row.

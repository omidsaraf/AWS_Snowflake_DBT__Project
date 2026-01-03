-- dbt/models/staging/stg_accounts.sql
{%- set yaml_metadata -%}
source_model: 'raw_accounts'
derived_columns:
  RECORD_SOURCE: '!S3_CORE_BANKING'
  LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
hashed_columns:
  ACCOUNT_HK: 'account_id'
  CUSTOMER_HK: 'customer_id'
  ACCOUNT_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'account_type'
      - 'balance'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata['source_model'],
                     derived_columns=metadata['derived_columns'],
                     hashed_columns=metadata['hashed_columns']) }}

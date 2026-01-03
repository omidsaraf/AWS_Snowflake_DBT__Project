-- dbt/models/staging/stg_accounts.sql
{%- set yaml_metadata -%}
source_model: 'raw_accounts'      -- Points to your source in sources.yml
derived_columns:
  RECORD_SOURCE: '!S3_CORE_BANKING'
  LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
hashed_columns:
  # Primary Hash Key for the Account Hub
  ACCOUNT_HK: 'account_id'
  
  # Hash Key for the relationship between Customer and Account (Link)
  CUSTOMER_ACCOUNT_HK:
    - 'customer_id'
    - 'account_id'
    
  # HashDiff for tracking changes in the Satellite (Balance/Type updates)
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

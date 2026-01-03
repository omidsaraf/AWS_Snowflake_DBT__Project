{%- set yaml_metadata -%}
source_model: 'raw_accounts'
derived_columns:
  RECORD_SOURCE: '!S3_BANKING_CORE'
  LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
hashed_columns:
  ACCOUNT_HK: 'ACCOUNT_ID'  -- Hashed Primary Key for the Hub
  ACCOUNT_HASHDIFF:         -- Tracks changes in the Satellite
    is_hashdiff: true
    columns:
      - 'ACCOUNT_TYPE'
      - 'BALANCE'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata['source_model'],
                     derived_columns=metadata['derived_columns'],
                     hashed_columns=metadata['hashed_columns']) }}

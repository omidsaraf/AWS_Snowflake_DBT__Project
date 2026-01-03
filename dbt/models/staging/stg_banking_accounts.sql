{%- set yaml_metadata -%}
source_model: 'raw_banking_accounts'
derived_columns:
  RECORD_SOURCE: '!AWS_S3_BANKING_SYSTEM'
  LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
hashed_columns:
  ACCOUNT_HK: 'ACCOUNT_ID'             -- Primary Hash Key for the Hub
  ACCOUNT_HASHDIFF:                    -- Checksum for tracking balance changes
    is_hashdiff: true
    columns:
      - 'ACCOUNT_TYPE'
      - 'CURRENT_BALANCE'
      - 'ACCOUNT_STATUS'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata['source_model'],
                     derived_columns=metadata['derived_columns'],
                     hashed_columns=metadata['hashed_columns']) }}

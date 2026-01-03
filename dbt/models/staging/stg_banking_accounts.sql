
{%- set yaml_metadata -%}
source_model: 'raw_accounts'
derived_columns:
  RECORD_SOURCE: '!AWS_S3_BANKING_CORE'
  LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
hashed_columns:
  # Primary Key for the Account Hub
  ACCOUNT_HK: 'account_id'
  
  # Business Key for the Customer Hub (for later joins)
  CUSTOMER_HK: 'customer_id'

  # Link Key: The unique relationship between a customer and an account
  LINK_CUSTOMER_ACCOUNT_HK:
    - 'customer_id'
    - 'account_id'
    
  # Change tracking for the Satellite
  ACCOUNT_HASHDIFF:   -- Checksum for tracking balance changes
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

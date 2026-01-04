{{
  config(
    materialized='incremental',
    unique_key='link_customer_account_key',
    tags=['link', 'customer', 'account']
  )
}}

{%- set source_model = ref('stg_accounts') -%}

WITH source_data AS (
    SELECT DISTINCT
        customer_id,
        account_id,
        record_source,
        load_datetime
    FROM {{ source_model }}
    {% if is_incremental() %}
        WHERE load_datetime > (SELECT MAX(load_datetime) FROM {{ this }})
    {% endif %}
),

hashed AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'account_id']) }} AS link_customer_account_key,
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS hub_customer_key,
        {{ dbt_utils.generate_surrogate_key(['account_id']) }} AS hub_account_key,
        customer_id,
        account_id,
        record_source,
        load_datetime
    FROM source_data
)

SELECT * FROM hashed


-- dbt/models/vault/links/link_customer_account.sql
-- {{ config(materialized='incremental') }}

-- {%- set yaml_metadata -%}
-- source_model: 'stg_banking_accounts'
-- src_pk: 'LINK_CUSTOMER_ACCOUNT_HK'
-- src_fk:
--   - 'CUSTOMER_HK'
--   - 'ACCOUNT_HK'
-- src_ldts: 'LOAD_DATETIME'
-- src_source: 'RECORD_SOURCE'
-- {%- endset -%}

-- {% set metadata = fromyaml(yaml_metadata) %}

-- {{ automate_dv.link(src_pk=metadata['src_pk'],
--                     src_fk=metadata['src_fk'],
--                     src_ldts=metadata['src_ldts'],
--                     src_source=metadata['src_source'],
--                     source_model=metadata['source_model']) }}

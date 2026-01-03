-- {{ config(
--     materialized='table'
-- ) }}

-- WITH staged AS (
--     SELECT
--         c.customer_id,
--         c.first_name,
--         c.last_name,
--         c.email,
--         CURRENT_TIMESTAMP() AS load_dts,
--         'source_system' AS record_source
--     FROM {{ ref('stg_customer') }} c
-- )

-- SELECT *
-- FROM staged
--- Satellites store descriptive attributes for hubs, historized with load timestamps.



-- dbt/models/vault/satellites/sat_customer_profile.sql
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_customer'
src_pk: 'CUSTOMER_HK'             -- Link back to the Customer Hub
src_hashdiff: 'CUSTOMER_HASHDIFF' -- Used to detect changes in the profile
src_payload:                      -- The descriptive attributes
  - 'first_name'
  - 'last_name'
  - 'email'
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



{{
  config(
    materialized='incremental',
    unique_key=['hub_customer_key', 'load_datetime']
  )
}}

-- WITH source_data AS (
--     SELECT
--         {{ dbt_utils.generate_surrogate_key(['customer_id', "'{{ var("source_system") }}'']) }} as hub_customer_key,
--         customer_name,
--         email,
--         phone,
--         address,
--         created_at,
--         updated_at,
--         {{ dbt_utils.current_timestamp() }} as load_datetime,
--         NULL as load_end_datetime
--     FROM {{ ref('stg_customers') }}
--     {% if is_incremental() %}
--         WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
--     {% endif %}
-- )

-- SELECT * FROM source_data


-- SCD Type 2 Behavior: Unlike a traditional database that overwrites john.doe@example.com, this Satellite keeps the old email and the new email with different LOAD_DATETIME stamps. This is critical for KYC (Know Your Customer) compliance.

-- Idempotency: Because it is materialized='incremental', you can run this model multiple times a day. It will only add data if there is a real change in the customer's attributes.

-- Zero-Update Architecture: In Snowflake, updates are expensive. Data Vault Satellites are insert-only, which is the most performant way to handle millions of banking records.

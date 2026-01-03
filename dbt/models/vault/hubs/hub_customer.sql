-- {{ config(
--     materialized='table'
-- ) }}

-- WITH staged AS (
--     SELECT DISTINCT
--         customer_id,
--         CURRENT_TIMESTAMP() AS load_dts,
--         'source_system' AS record_source
--     FROM {{ ref('stg_customer') }}
-- )

-- SELECT *
-- FROM staged
--- Hub tables store unique business keys (customer_id) with load timestamps and source info.

---method2
-- dbt/models/vault/hubs/hub_customer.sql
-- {{ config(materialized='incremental') }}

-- {%- set source_model = "stg_customers" -%}
-- {%- set src_pk = "CUSTOMER_HK" -%}
-- {%- set src_nk = "customer_id" -%}
-- {%- set src_ldts = "LOAD_DATETIME" -%}
-- {%- set src_source = "RECORD_SOURCE" -%}

-- {{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, 
--                    src_ldts=src_ldts, src_source=src_source,
--                    source_model=source_model) }}


{{
  config(
    materialized='incremental',
    unique_key='hub_customer_key'
  )
}}

WITH source_data AS (
    SELECT DISTINCT
        customer_id,
        '{{ var("source_system") }}' as record_source,
        {{ dbt_utils.current_timestamp() }} as load_datetime
    FROM {{ ref('stg_customers') }}
    {% if is_incremental() %}
        WHERE load_datetime > (SELECT MAX(load_datetime) FROM {{ this }})
    {% endif %}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['customer_id', 'record_source']) }} as hub_customer_key,
    customer_id,
    record_source,
    load_datetime
FROM source_data

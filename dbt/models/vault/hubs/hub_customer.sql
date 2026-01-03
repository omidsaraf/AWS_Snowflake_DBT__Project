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


-- dbt/models/vault/hubs/hub_customer.sql
{{ config(materialized='incremental') }}

{%- set source_model = "stg_customers" -%}
{%- set src_pk = "CUSTOMER_HK" -%}
{%- set src_nk = "customer_id" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, 
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

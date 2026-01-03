{{ config(
    materialized='table'
) }}

WITH staged AS (
    SELECT DISTINCT
        customer_id,
        CURRENT_TIMESTAMP() AS load_dts,
        'source_system' AS record_source
    FROM {{ ref('stg_customer') }}
)

SELECT *
FROM staged
--- Hub tables store unique business keys (customer_id) with load timestamps and source info.

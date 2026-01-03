{{ config(
    materialized='table'
) }}

WITH staged AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        CURRENT_TIMESTAMP() AS load_dts,
        'source_system' AS record_source
    FROM {{ ref('stg_customer') }} c
)

SELECT *
FROM staged
--- Satellites store descriptive attributes for hubs, historized with load timestamps.

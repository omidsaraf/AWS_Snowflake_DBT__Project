{{ config(
    materialized='table'
) }}

WITH staged AS (
    SELECT DISTINCT
        c.customer_id,
        a.account_id,
        CURRENT_TIMESTAMP() AS load_dts,
        'source_system' AS record_source
    FROM {{ ref('stg_customer') }} c
    JOIN {{ source('raw_bronze', 'account') }} a
        ON c.customer_id = a.customer_id
)

SELECT *
FROM staged
--- Link tables connect hubs (customer → account) with load metadata.

{{ config(
    materialized='view'
) }}

WITH raw AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        email,
        created_at,
        updated_at
    FROM {{ source('raw_bronze', 'customer') }}
)

SELECT *
FROM raw
---- Cleans and standardizes raw Bronze data for hubs and satellites.

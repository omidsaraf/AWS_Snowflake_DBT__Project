{{
  config(
    materialized='view',
    tags=['staging', 'customers']
  )
}}

WITH source AS (
    SELECT * FROM {{ source('raw_banking', 'customers') }}
),

renamed AS (
    SELECT
        -- Business Keys
        customer_id,
        
        -- Descriptive Attributes
        TRIM(customer_name) AS customer_name,
        LOWER(TRIM(email)) AS email,
        phone,
        date_of_birth,
        
        -- Metadata
        created_at,
        updated_at,
        '{{ var("source_system") }}' AS record_source,
        {{ dbt_utils.current_timestamp() }} AS load_datetime
        
    FROM source
    WHERE customer_id IS NOT NULL
)

SELECT * FROM renamed
---- Cleans and standardizes raw Bronze data for hubs and satellites.
-- dbt/models/staging/stg_customer.sql
-- {%- set yaml_metadata -%}
-- source_model: 'raw_customers'       -- Mapping from your sources.yml
-- derived_columns:
--   RECORD_SOURCE: '!S3_CORE_BANKING' -- Constant to identify the origin
--   LOAD_DATETIME: 'CURRENT_TIMESTAMP()'
-- hashed_columns:
--   # Business Key Hash for HUB_CUSTOMER
--   CUSTOMER_HK: 'customer_id'
  
--   # Change tracking hash for SAT_CUSTOMER_DETAILS
--   CUSTOMER_HASHDIFF:
--     is_hashdiff: true
--     columns:
--       - 'first_name'
--       - 'last_name'
--       - 'email'
-- {%- endset -%}

-- {% set metadata = fromyaml(yaml_metadata) %}

-- {{ automate_dv.stage(include_source_columns=true,
--                      source_model=metadata['source_model'],
                     derived_columns=metadata['derived_columns'],
                     hashed_columns=metadata['hashed_columns']) }}

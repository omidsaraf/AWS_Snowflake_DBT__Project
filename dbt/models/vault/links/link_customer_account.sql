-- {{ config(
--     materialized='table'
-- ) }}

-- WITH staged AS (
--     SELECT DISTINCT
--         c.customer_id,
--         a.account_id,
--         CURRENT_TIMESTAMP() AS load_dts,
--         'source_system' AS record_source
--     FROM {{ ref('stg_customer') }} c
--     JOIN {{ source('raw_bronze', 'account') }} a
--         ON c.customer_id = a.customer_id
-- )

-- SELECT *
-- FROM staged
--- Link tables connect hubs (customer → account) with load metadata.


-- dbt/models/vault/links/link_customer_account.sql
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_banking_accounts'
src_pk: 'LINK_CUSTOMER_ACCOUNT_HK'
src_fk:
  - 'CUSTOMER_HK'
  - 'ACCOUNT_HK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata['src_pk'],
                    src_fk=metadata['src_fk'],
                    src_ldts=metadata['src_ldts'],
                    src_source=metadata['src_source'],
                    source_model=metadata['source_model']) }}

{{ config(materialized='incremental') }}

{%- set source_model = "stg_banking_accounts" -%}
{%- set src_pk = "ACCOUNT_HK" -%}
{%- set src_nk = "ACCOUNT_ID" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, 
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

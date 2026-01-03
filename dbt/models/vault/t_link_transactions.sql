-- dbt/models/vault/links/t_link_transactions.sql
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_transactions'
src_pk: 'TRANSACTION_HK'           -- Unique ID for the transaction
src_fk: 'ACCOUNT_HK'               -- Foreign key to the Account Hub
src_payload:                        -- The actual transaction data
  - 'transaction_date'
  - 'amount'
  - 'transaction_type'
  - 'merchant_name'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata = fromyaml(yaml_metadata) %}

{{ automate_dv.t_link(src_pk=metadata['src_pk'],
                      src_fk=metadata['src_fk'],
                      src_payload=metadata['src_payload'],
                      src_ldts=metadata['src_ldts'],
                      src_source=metadata['src_source'],
                      source_model=metadata['source_model']) }}

-- Why use a T-Link for Banking?
-- Immutable Ledger: In banking, you never "update" a transaction. If a mistake is made, a second "reversal" transaction is created. The T-Link perfectly mirrors this real-world accounting practice.

-- Performance: By keeping the amount in the Link, you don't have to join a Satellite to see how much money moved. This makes balance aggregation (Sum of Amounts) extremely fast in Snowflake.

-- Auditability: Every row contains the RECORD_SOURCE. If there is a discrepancy in the ledger, you can trace the specific transaction back to the exact S3 file it arrived in.

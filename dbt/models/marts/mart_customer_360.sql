{{ config(materialized='table') }}

WITH latest_customer_details AS (
    -- Get the most recent profile info (name, email)
    SELECT *
    FROM {{ ref('sat_customer_profile') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY CUSTOMER_HK ORDER BY LOAD_DATETIME DESC) = 1
),

latest_balances AS (
    -- Get the most recent balance for every account
    SELECT *
    FROM {{ ref('sat_account_balance') }}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ACCOUNT_HK ORDER BY LOAD_DATETIME DESC) = 1
)

SELECT
    h_cust.customer_id,
    cp.first_name,
    cp.last_name,
    cp.email,
    h_acc.account_id,
    ab.account_type,
    ab.balance,
    ab.LOAD_DATETIME AS last_updated
FROM {{ ref('hub_customer') }} h_cust
-- Join the profile details
LEFT JOIN latest_customer_details cp 
    ON h_cust.CUSTOMER_HK = cp.CUSTOMER_HK
-- Link Customers to their Accounts
INNER JOIN {{ ref('link_customer_account') }} l_ca 
    ON h_cust.CUSTOMER_HK = l_ca.CUSTOMER_HK
INNER JOIN {{ ref('hub_account') }} h_acc 
    ON l_ca.ACCOUNT_HK = h_acc.ACCOUNT_HK
-- Join the balance details
LEFT JOIN latest_balances ab 
    ON h_acc.ACCOUNT_HK = ab.ACCOUNT_HK

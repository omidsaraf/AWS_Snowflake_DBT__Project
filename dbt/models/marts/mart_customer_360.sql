{{
  config(
    materialized='table',
    tags=['marts', 'customer_360']
  )
}}

WITH customers AS (
    SELECT
        hub.hub_customer_key,
        hub.customer_id,
        sat.customer_name,
        sat.email,
        sat.phone,
        sat.date_of_birth,
        DATEDIFF('year', sat.date_of_birth, CURRENT_DATE()) AS age
    FROM {{ ref('hub_customer') }} hub
    LEFT JOIN {{ ref('sat_customer_details') }} sat
        ON hub.hub_customer_key = sat.hub_customer_key
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY hub.hub_customer_key 
        ORDER BY sat.load_datetime DESC
    ) = 1
),

accounts AS (
    SELECT
        link.hub_customer_key,
        COUNT(DISTINCT hub_acc.account_id) AS total_accounts,
        SUM(CASE WHEN sat_acc.status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_accounts,
        SUM(sat_acc.balance) AS total_balance
    FROM {{ ref('link_customer_account') }} link
    LEFT JOIN {{ ref('hub_account') }} hub_acc
        ON link.hub_account_key = hub_acc.hub_account_key
    LEFT JOIN {{ ref('sat_account_details') }} sat_acc
        ON hub_acc.hub_account_key = sat_acc.hub_account_key
    WHERE sat_acc.load_datetime = (
        SELECT MAX(load_datetime) 
        FROM {{ ref('sat_account_details') }} sub
        WHERE sub.hub_account_key = sat_acc.hub_account_key
    )
    GROUP BY link.hub_customer_key
),

transactions AS (
    SELECT
        link_ca.hub_customer_key,
        COUNT(DISTINCT hub_txn.transaction_id) AS total_transactions,
        SUM(sat_txn.amount) AS total_transaction_amount,
        MAX(sat_txn.transaction_datetime) AS last_transaction_date
    FROM {{ ref('link_customer_account') }} link_ca
    INNER JOIN {{ ref('link_account_transaction') }} link_at
        ON link_ca.hub_account_key = link_at.hub_account_key
    INNER JOIN {{ ref('hub_transaction') }} hub_txn
        ON link_at.hub_transaction_key = hub_txn.hub_transaction_key
    LEFT JOIN {{ ref('sat_transaction_details') }} sat_txn
        ON hub_txn.hub_transaction_key = sat_txn.hub_transaction_key
    GROUP BY link_ca.hub_customer_key
)

SELECT
    c.hub_customer_key,
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone,
    c.age,
    COALESCE(a.total_accounts, 0) AS total_accounts,
    COALESCE(a.active_accounts, 0) AS active_accounts,
    COALESCE(a.total_balance, 0) AS total_balance,
    COALESCE(t.total_transactions, 0) AS total_transactions,
    COALESCE(t.total_transaction_amount, 0) AS total_transaction_amount,
    t.last_transaction_date,
    CURRENT_TIMESTAMP() AS generated_at
FROM customers c
LEFT JOIN accounts a ON c.hub_customer_key = a.hub_customer_key
LEFT JOIN transactions t ON c.hub_customer_key = t.hub_customer_key

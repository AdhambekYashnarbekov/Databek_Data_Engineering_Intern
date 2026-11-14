{{
    config(
        materialized='incremental',
        unique_key='revenue_date',
        incremental_strategy='delete+insert'
    )
}}

SELECT
    order_date AS revenue_date,
    COUNT(DISTINCT order_id) AS total_completed_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COALESCE(SUM(total_amount), 0) AS total_revenue,
    CURRENT_TIMESTAMP AS updated_at
FROM {{ ref('stg_orders') }}
WHERE status = 'completed'

{% if is_incremental() %}
  -- Re-process recent days safely to maintain idempotency
  AND order_date >= (SELECT COALESCE(MAX(revenue_date) - INTERVAL '3 days', '1900-01-01') FROM {{ this }})
{% endif %}

GROUP BY order_date

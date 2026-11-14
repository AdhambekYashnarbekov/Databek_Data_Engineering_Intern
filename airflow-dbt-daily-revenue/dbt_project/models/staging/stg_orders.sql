SELECT
    order_id,
    customer_id,
    order_date,
    LOWER(TRIM(status)) AS status,
    total_amount,
    loaded_at
FROM staging.orders
WHERE order_id IS NOT NULL

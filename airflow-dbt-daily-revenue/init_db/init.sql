CREATE DATABASE analytics;
\c analytics;

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;

CREATE TABLE IF NOT EXISTS raw.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed sample data for yesterday and two days ago
INSERT INTO raw.orders (order_id, customer_id, order_date, status, total_amount)
VALUES
    ('ORD-1001', 'CUST-01', CURRENT_DATE - INTERVAL '1 day', 'completed', 150.00),
    ('ORD-1002', 'CUST-02', CURRENT_DATE - INTERVAL '1 day', 'completed', 89.50),
    ('ORD-1003', 'CUST-03', CURRENT_DATE - INTERVAL '1 day', 'cancelled', 45.00),
    ('ORD-1000', 'CUST-01', CURRENT_DATE - INTERVAL '2 days', 'completed', 210.00)
ON CONFLICT (order_id) DO NOTHING;

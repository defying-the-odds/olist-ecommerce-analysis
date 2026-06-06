-- ================================================
-- Revenue & Profitability Analysis
-- Project: Olist E-Commerce Analysis
-- ================================================

-- Query 1: Total Revenue (delivered orders only)
SELECT ROUND(SUM(p.payment_value), 2) as total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered';

-- Query 2: Monthly Revenue Trend
SELECT 
    strftime('%Y-%m', o.order_purchase_timestamp) as month,
    ROUND(SUM(p.payment_value), 2) as monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Query 3: Average Order Value
WITH order_totals AS (
    SELECT 
        o.order_id,
        SUM(p.payment_value) as order_total
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p 
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
)
SELECT 
    ROUND(AVG(order_total), 2) as avg_order_value
FROM order_totals;

-- Query 4: Revenue by Payment Type
SELECT 
    p.payment_type,
    COUNT(DISTINCT p.order_id) as total_orders,
    ROUND(SUM(p.payment_value), 2) as total_revenue,
    ROUND(AVG(p.payment_value), 2) as avg_payment
FROM olist_order_payments_dataset p
JOIN olist_orders_dataset o 
    ON p.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_revenue DESC;

-- ================================================
-- Business Health Analysis
-- Project: Olist E-Commerce Analysis
-- ================================================

-- Query 15: Delivery Time vs Review Score
SELECT 
    CASE 
        WHEN JULIANDAY(o.order_delivered_customer_date) - 
             JULIANDAY(o.order_purchase_timestamp) <= 7 THEN '0-7 days'
        WHEN JULIANDAY(o.order_delivered_customer_date) - 
             JULIANDAY(o.order_purchase_timestamp) <= 14 THEN '8-14 days'
        WHEN JULIANDAY(o.order_delivered_customer_date) - 
             JULIANDAY(o.order_purchase_timestamp) <= 21 THEN '15-21 days'
        ELSE '22+ days'
    END as delivery_time,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(r.review_score), 2) as avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_time
ORDER BY avg_review_score DESC;

-- Query 16: Seasonal Revenue Trends (2016 excluded - incomplete data)
SELECT 
    strftime('%m', o.order_purchase_timestamp) as month_number,
    CASE strftime('%m', o.order_purchase_timestamp)
        WHEN '01' THEN 'January'
        WHEN '02' THEN 'February'
        WHEN '03' THEN 'March'
        WHEN '04' THEN 'April'
        WHEN '05' THEN 'May'
        WHEN '06' THEN 'June'
        WHEN '07' THEN 'July'
        WHEN '08' THEN 'August'
        WHEN '09' THEN 'September'
        WHEN '10' THEN 'October'
        WHEN '11' THEN 'November'
        WHEN '12' THEN 'December'
    END as month_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value), 2) as total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
AND strftime('%Y', o.order_purchase_timestamp) != '2016'
GROUP BY month_number
ORDER BY month_number;

-- Query 17: Average Delivery Time and Review Score by State (Slowest First)
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(JULIANDAY(o.order_delivered_customer_date) - 
        JULIANDAY(o.order_purchase_timestamp)), 1) as avg_delivery_days,
    ROUND(AVG(r.review_score), 2) as avg_review_score
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC
LIMIT 15;

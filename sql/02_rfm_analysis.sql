-- ================================================
-- RFM Customer Segmentation Analysis
-- Project: Olist E-Commerce Analysis
-- ================================================

-- Query 5: Raw RFM Values (Recency, Frequency, Monetary per customer)
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) as last_purchase,
        COUNT(DISTINCT o.order_id) as frequency,
        ROUND(SUM(p.payment_value), 2) as monetary
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o 
        ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p 
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    customer_unique_id,
    CAST(julianday('2018-10-17') - julianday(last_purchase) AS INTEGER) as recency_days,
    frequency,
    monetary
FROM customer_orders
ORDER BY monetary DESC
LIMIT 10;

-- Query 6: RFM Scores (Score each customer 1-3 on each dimension)
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        CAST(julianday('2018-10-17') - julianday(MAX(o.order_purchase_timestamp)) AS INTEGER) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        ROUND(SUM(p.payment_value), 2) as monetary
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        CASE 
            WHEN recency_days <= 90 THEN 3
            WHEN recency_days <= 270 THEN 2
            ELSE 1 
        END as r_score,
        CASE 
            WHEN frequency >= 3 THEN 3
            WHEN frequency = 2 THEN 2
            ELSE 1 
        END as f_score,
        CASE 
            WHEN monetary >= 500 THEN 3
            WHEN monetary >= 150 THEN 2
            ELSE 1 
        END as m_score
    FROM customer_orders
)
SELECT *
FROM rfm_scores
LIMIT 10;

-- Query 7: RFM Segments (Combine scores into named customer segments)
WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        CAST(julianday('2018-10-17') - julianday(MAX(o.order_purchase_timestamp)) AS INTEGER) as recency_days,
        COUNT(DISTINCT o.order_id) as frequency,
        ROUND(SUM(p.payment_value), 2) as monetary
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        CASE 
            WHEN recency_days <= 90 THEN 3
            WHEN recency_days <= 270 THEN 2
            ELSE 1 
        END as r_score,
        CASE 
            WHEN frequency >= 3 THEN 3
            WHEN frequency = 2 THEN 2
            ELSE 1 
        END as f_score,
        CASE 
            WHEN monetary >= 500 THEN 3
            WHEN monetary >= 150 THEN 2
            ELSE 1 
        END as m_score
    FROM customer_orders
)
SELECT 
    CASE 
        WHEN r_score = 3 AND f_score >= 2 THEN 'Champion'
        WHEN r_score = 3 AND f_score = 1 THEN 'Recent Customer'
        WHEN r_score = 2 AND f_score >= 2 THEN 'Loyal Customer'
        WHEN r_score = 2 AND f_score = 1 AND m_score >= 2 THEN 'Potential Loyalist'
        WHEN r_score = 1 AND f_score >= 2 THEN 'At Risk'
        WHEN r_score = 1 AND f_score = 1 AND m_score >= 2 THEN 'Needs Attention'
        ELSE 'Lost'
    END as segment,
    COUNT(*) as total_customers,
    ROUND(AVG(monetary), 2) as avg_spend,
    ROUND(AVG(recency_days), 2) as avg_recency_days
FROM rfm_scores
GROUP BY segment
ORDER BY avg_spend DESC;

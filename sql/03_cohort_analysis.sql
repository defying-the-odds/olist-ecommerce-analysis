-- ================================================
-- Cohort Retention Analysis
-- Project: Olist E-Commerce Analysis
-- ================================================

-- Query 8: Find Each Customer's First Purchase Month
WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(strftime('%Y-%m', o.order_purchase_timestamp)) as cohort_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o 
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT *
FROM first_purchase
LIMIT 10;

-- Query 9: Calculate Months Since First Purchase Per Order
WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(strftime('%Y-%m', o.order_purchase_timestamp)) as cohort_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o 
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
order_months AS (
    SELECT 
        c.customer_unique_id,
        f.cohort_month,
        strftime('%Y-%m', o.order_purchase_timestamp) as order_month,
        CAST((
            (strftime('%Y', o.order_purchase_timestamp) - strftime('%Y', f.cohort_month || '-01')) * 12 +
            (strftime('%m', o.order_purchase_timestamp) - strftime('%m', f.cohort_month || '-01'))
        ) AS INTEGER) as months_since_first
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN first_purchase f ON c.customer_unique_id = f.customer_unique_id
    WHERE o.order_status = 'delivered'
)
SELECT *
FROM order_months
LIMIT 10;

-- Query 10: Full Cohort Retention Grid (Months 0-6)
WITH first_purchase AS (
    SELECT 
        c.customer_unique_id,
        MIN(strftime('%Y-%m', o.order_purchase_timestamp)) as cohort_month
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o 
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
order_months AS (
    SELECT 
        c.customer_unique_id,
        f.cohort_month,
        CAST((
            (strftime('%Y', o.order_purchase_timestamp) - strftime('%Y', f.cohort_month || '-01')) * 12 +
            (strftime('%m', o.order_purchase_timestamp) - strftime('%m', f.cohort_month || '-01'))
        ) AS INTEGER) as months_since_first
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    JOIN first_purchase f ON c.customer_unique_id = f.customer_unique_id
    WHERE o.order_status = 'delivered'
),
cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_unique_id) as total_customers
    FROM first_purchase
    GROUP BY cohort_month
),
retention AS (
    SELECT 
        o.cohort_month,
        o.months_since_first,
        COUNT(DISTINCT o.customer_unique_id) as returning_customers
    FROM order_months o
    GROUP BY o.cohort_month, o.months_since_first
)
SELECT 
    r.cohort_month,
    c.total_customers,
    r.months_since_first,
    r.returning_customers,
    ROUND(CAST(r.returning_customers AS FLOAT) / c.total_customers * 100, 1) as retention_rate
FROM retention r
JOIN cohort_size c ON r.cohort_month = c.cohort_month
WHERE r.months_since_first <= 6
ORDER BY r.cohort_month, r.months_since_first;

-- ================================================
-- Product & Category Performance Analysis
-- Project: Olist E-Commerce Analysis
-- ================================================

-- Query 11: Revenue by Category (Top 15)
SELECT 
    t.product_category_name_english as category,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(i.price), 2) as total_revenue,
    ROUND(AVG(i.price), 2) as avg_price
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_products_dataset p ON i.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 15;

-- Query 12: Category Review Scores (Lowest Rated First)
SELECT 
    t.product_category_name_english as category,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(r.review_score), 2) as avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_products_dataset p ON i.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY avg_review_score ASC
LIMIT 15;

-- Query 13: High Volume Low Rating Risk Flags
SELECT 
    t.product_category_name_english as category,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(r.review_score), 2) as avg_review_score,
    ROUND(SUM(i.price), 2) as total_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_products_dataset p ON i.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
HAVING total_orders > 1000 AND avg_review_score < 4.0
ORDER BY total_orders DESC;

-- Query 14: Top 10 Products by Revenue
SELECT 
    i.product_id,
    t.product_category_name_english as category,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(i.price), 2) as total_revenue,
    ROUND(AVG(i.price), 2) as avg_price
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN olist_products_dataset p ON i.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY i.product_id, category
ORDER BY total_revenue DESC
LIMIT 10;

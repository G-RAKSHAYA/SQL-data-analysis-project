  -- /*===============================================================================
-- Customer Report
-- ===============================================================================
-- Purpose:
   --  - This report consolidates key customer metrics and behaviors

-- Highlights:
 --   1. Gathers essential fields such as names, ages, and transaction details.
-- 2. Segments customers into categories (VIP, Regular, New) and age groups.
--  3. Aggregates customer-level metrics:
-- - total orders
--         total sales
	--    - total quantity purchased
-- 	   - total products
-- 	   - lifespan (in months)
 --   4. Calculates valuable KPIs:
-- 	    - recency (months since last order)
-- 		- average order value
-- 		- average monthly spend
-- ===============================================================================
-- 1 Base Query: Retrieves core columns from tables







CREATE VIEW `gold_report_-customer` AS

-- (Your existing SELECT query here)

with base_query as (
SELECT 
    f.order_number,
    f.order_date,
    f.product_key,
    f.quantity,
    f.sales_amount,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS age
 FROM test.`gold.fact_sales` f
LEFT JOIN test.`gold.dim_customers` c ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL) 

-- ============================================
-- 2. Customer-Level Aggregations
-- ============================================
, customer_aggregation AS (
    SELECT 
        customer_key, 
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan -- Corrected life_span calculation
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)

-- ============================================
-- 3. Customer Segmentation
-- ============================================
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    
    -- Age Group Classification
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    -- Customer Segmentation Logic
    CASE 
        WHEN lifespan >= 3 AND total_sales > 3000 THEN 'VIP'
        WHEN lifespan >= 3 AND total_sales <= 3000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    last_order_date,
     timestampdiff(month, last_order_date, curdate()) AS recency,
     total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    
    -- Compuate average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Compuate average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation;










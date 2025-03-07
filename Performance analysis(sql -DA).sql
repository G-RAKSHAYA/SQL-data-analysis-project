-- performance analysis 
 
USE test;  -- ✅ Select the database

select product_name from test.`gold.dim_products`;
UPDATE test.`gold.dim_products`  
SET product_name = 'Unknown Product'  
WHERE product_name REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'  
ORDER BY product_name  
LIMIT 10; 


WITH yearly_product_sales AS (
    SELECT 
        MONTH(f.order_date) AS order_month, 
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM test.`gold.fact_sales` f
    LEFT JOIN test.`gold.dim_products` p
    ON f.product_key = p.product_key 
    WHERE MONTH(f.order_date) IS NOT NULL AND p.product_name IS NOT NULL
    GROUP BY order_month, p.product_name
) 
SELECT order_month, product_name , current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS diff_py,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
    FROM yearly_product_sales   
ORDER BY product_name , order_month;
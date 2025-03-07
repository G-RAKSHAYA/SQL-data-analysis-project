--  part to whole 
-- which category contribute more in the overall sales 

select category, sum(sales_amount)  FROM test.`gold.fact_sales` f
    LEFT JOIN test.`gold.dim_products` p
    ON f.product_key = p.product_key 
    where category is  null 
    group by category;
 
 
 USE test;  -- ✅ Select the database

select category from test.`gold.dim_products`;
UPDATE test.`gold.dim_products`  
SET category = 'Unknown Product'  
WHERE category REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'  
ORDER BY category 
LIMIT 10; 

SELECT COUNT(*) 
FROM test.`gold.dim_products`
WHERE category IS NULL;

SELECT COUNT(*) 
FROM test.`gold.dim_products`
WHERE TRIM(category) = '';
 
 UPDATE test.`gold.dim_products`  
SET category = 'Unknown Category'  
WHERE (category) = null
ORDER BY product_key
LIMIT 10;
;

with category_sales as 
 (select category, sum(sales_amount) as total_sales FROM test.`gold.fact_sales` f
    LEFT JOIN test.`gold.dim_products` p
    ON f.product_key = p.product_key 
    where category is not  null 
    group by category) 
    
 SELECT category, 
         total_sales,
       SUM(total_sales) OVER () AS overall_sales,
       CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
ORDER BY total_sales DESC;
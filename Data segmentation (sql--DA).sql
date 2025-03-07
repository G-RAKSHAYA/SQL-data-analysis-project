-- data segmentation 

with product_segment as (
select 
product_key,
product_name,
cost,
case 
when cost < 50  then 'Below 50'
when cost between 50 and 100 then '50-100'
when cost between 100 and 500 then '100-500'
when cost between 500 and 800 then '500-800'
else 1000
end cost_range
from test.`gold.dim_products`)

select cost_range, 
count(product_key) as total_product
from product_segment 
group by cost_range;



-- grp customer into 3 segments 
-- vip atleast 3 month of istory and spending more than 3000
-- - Regular: Customers with at least 3 months of history but spending €3,000 or less.
-- New: Customers with a lifespan less than 3 months. And find the total number of customers by each group





WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM test.`gold.fact_sales` f
    LEFT JOIN test.`gold.dim_customers` c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 3 AND total_spending > 3000 THEN 'VIP'
            WHEN lifespan >= 3  AND total_spending <= 3000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;



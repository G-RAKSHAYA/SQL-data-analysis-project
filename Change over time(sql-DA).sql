-- CHANGE OVER TIME 
SELECT 
    DATE_FORMAT(order_date, '%Y-%b') AS month_year, 
    SUM(sales_amount) AS totalsales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(QUANTITY) AS TOTAL_QUANTITY
FROM test.`gold.fact_sales`
WHERE order_date IS NOT NULL AND order_date <> ''
GROUP BY month_year
ORDER BY month_year;

-- cumulative analysis-- 
-- running sales over time , total sales per month 


WITH sales_aggregated AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,  -- Use YYYY-MM for correct ordering
        SUM(sales_amount) AS totalsales,
        avg(price) as avg_price
    FROM test.`gold.fact_sales`
    WHERE order_date IS NOT NULL AND order_date <> ''
    GROUP BY order_month
)
SELECT 
    order_month, 
    totalsales, 
    SUM(totalsales) OVER (ORDER BY order_month) AS running_salestotal,
    avg(avg_price) OVER (ORDER BY order_month) AS movingAVGprice
FROM sales_aggregated
ORDER BY order_month;

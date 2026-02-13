WITH sales_data AS (
    SELECT * FROM {{ ref('prep_sales') }}
)

SELECT
    order_year,
    order_month,
    category_name,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(*) AS total_line_items,
    SUM(quantity) AS total_units_sold,
    SUM(revenue)::NUMERIC(10,2) AS total_revenue,
    ROUND(
        AVG(revenue)::NUMERIC,
        2
    ) AS avg_revenue_per_order,
    ROUND(
        SUM(revenue) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS revenue_per_order
FROM sales_data
GROUP BY 1, 2, 3
ORDER BY 
    category_name,
    order_year,
    order_month
WITH orders AS (
    SELECT * FROM {{ ref('staging_orders') }}
),

order_details AS (
    SELECT * FROM {{ ref('staging_order_details') }}
),

products AS (
    SELECT * FROM {{ ref('staging_products') }}
),

categories AS (
    SELECT * FROM {{ ref('staging_categories') }}
),

joined_data AS (
    SELECT
        -- Order info
        o.order_id,
        o.customer_id,
        o.order_date,
        
        -- Product info
        p.product_name,
        c.category_name,
        
        -- Sales metrics
        od.unit_price,
        od.quantity,
        od.discount,
        
        -- CALCULATED: This is the key business logic!
        ROUND(
            (od.unit_price * od.quantity * (1 - od.discount))::NUMERIC,
            2
        ) AS revenue,
        
        -- Date parts for aggregation
        EXTRACT(YEAR FROM o.order_date)::INTEGER AS order_year,
        EXTRACT(MONTH FROM o.order_date)::INTEGER AS order_month
        
    FROM orders o
    INNER JOIN order_details od ON o.order_id = od.order_id
    INNER JOIN products p ON od.product_id = p.product_id
    LEFT JOIN categories c ON p.category_id = c.category_id
)

SELECT * FROM joined_data

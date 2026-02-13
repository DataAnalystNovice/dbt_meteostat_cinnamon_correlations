WITH source AS (
    SELECT * 
    FROM {{ source('northwind_data', 'order_details') }}  -- Changed source name
)

SELECT
    orderid AS order_id,
    productid AS product_id,
    unitprice::NUMERIC(10,2) AS unit_price,
    quantity::INTEGER AS quantity,
    discount::NUMERIC(3,2) AS discount
FROM source
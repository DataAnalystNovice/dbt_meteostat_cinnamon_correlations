WITH source AS (
    SELECT * FROM {{ source('northwind', 'order_details') }}
)

SELECT
    orderid AS order_id,
    productid AS product_id,
    unitprice::NUMERIC(10,2) AS unit_price,
    quantity::INTEGER AS quantity,
    discount::NUMERIC(3,2) AS discount
FROM source
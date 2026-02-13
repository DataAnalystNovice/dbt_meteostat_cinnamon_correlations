WITH source AS (
    SELECT * FROM {{ source('northwind', 'products') }}
)

SELECT
    productid AS product_id,
    productname AS product_name,
    supplierid AS supplier_id,
    categoryid AS category_id,
    unitprice::NUMERIC(10,2) AS unit_price
FROM source
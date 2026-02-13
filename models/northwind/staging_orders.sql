WITH source AS (
    SELECT * FROM {{ source('northwind', 'orders') }}
)

SELECT
    orderid AS order_id,
    customerid AS customer_id,
    employeeid AS employee_id,
    orderdate::DATE AS order_date,
    requireddate::DATE AS required_date,
    shippeddate::DATE AS shipped_date,
    shipvia AS ship_via,
    shipcity AS ship_city,
    shipcountry AS ship_country
FROM source
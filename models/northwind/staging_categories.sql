WITH source AS (
    SELECT * FROM {{ source('northwind', 'categories') }}
)

SELECT
    categoryid AS category_id,
    categoryname AS category_name
FROM source
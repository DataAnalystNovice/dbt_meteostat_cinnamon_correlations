WITH source AS (
    SELECT * 
    FROM {{ source('northwind_data', 'categories') }}  -- Changed source name
)

SELECT
    categoryid AS category_id,
    categoryname AS category_name
FROM source
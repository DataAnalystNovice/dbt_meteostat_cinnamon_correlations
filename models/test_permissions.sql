{{ config(materialized='table') }}

SELECT 
    1 as id,
    'test' as name
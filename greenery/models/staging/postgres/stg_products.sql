{{
  config(
    materialized='table'
  )
}}

SELECT 
    product_id as product_guid
    , name
    , price
    , inventory   
FROM {{ source('postgres', 'products') }}
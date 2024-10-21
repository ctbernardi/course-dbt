{{
  config(
    materialized='table'
  )
}}

SELECT 
    product_id as product_guid
    , name as product_name
    , price
    , inventory 
    , case when price < 20 then '1'
           when price >= 20 and price < 50 then '2' 
           when price >= 50 then '3'
      else NULL end as  product_type_id
FROM {{ source('postgres', 'products') }}
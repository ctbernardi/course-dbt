{{
  config(
    materialized='table'
  )
}}

select 
    a.product_guid
    , a.product_name
    , a.price
    , a.inventory 
    , b.product_type 
from {{ref('base_products')}} a
left join {{ref('base_product_types')}} b on a.product_type_id = b.product_type_id
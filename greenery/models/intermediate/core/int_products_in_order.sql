{{
  config(
    materialized='table'
  )
}}

select order_guid
    , count(distinct product_guid) as products_in_order
from {{ref('stg_order_items')}}
group by 1

{{
  config(
    materialized='table'
  )
}}

select a.user_guid
    , count(distinct b.product_guid) as products_purchased
from {{ref('stg_orders')}} a
left join {{ref('stg_order_items')}} b on a.order_guid = b.order_guid
group by 1
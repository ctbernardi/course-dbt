{{
  config(
    materialized='table'
  )
}}

select user_guid
    , min(created_at_utc) as first_order_created_at_utc
    , max(created_at_utc) as last_order_created_at_utc
    , sum(order_cost) as total_spend
    , count(distinct order_guid) as num_orders
from {{ref('stg_orders')}}
group by 1
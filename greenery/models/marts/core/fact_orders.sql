{{
  config(
    materialized='table'
  )
}}

with orders as
(select *
from {{ref('stg_orders')}}) ,

addresses as 
(select *
from {{ref('stg_addresses')}}) ,

promos as 
(select *
from {{ref('stg_promos')}})

select a.order_guid
    , a.user_guid
    , a.address_guid
    , b.country
    , b.state
    , a.created_at_utc
    , a.order_cost
    , a.shipping_cost
    , a.order_total
    , a.tracking_guid
    , a.shipping_service
    , a.estimated_delivery_at_utc
    , a.delivered_at_utc
    , a.order_status
    , c.products_in_order
    , d.promo_name
    , d.discount
    , d.promo_status
from orders a
left join addresses b on a.address_guid = b.address_guid
left join {{ref('int_products_in_order')}} c on a.order_guid = c.order_guid
left join promos d on a.promo_name = d.promo_name
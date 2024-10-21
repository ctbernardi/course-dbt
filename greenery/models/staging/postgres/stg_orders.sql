{{
  config(
    materialized='table'
  )
}}

SELECT 
    order_id as order_guid
    , user_id as user_guid
    , promo_id as promo_name
    , address_id as address_guid
    , created_at as created_at_utc
    , order_cost
    , shipping_cost
    , order_total
    , tracking_id as tracking_guid
    , shipping_service
    , estimated_delivery_at as estimated_delivery_at_utc
    , delivered_at as delivered_at_utc
    , status as order_status
FROM {{ source('postgres', 'orders') }}
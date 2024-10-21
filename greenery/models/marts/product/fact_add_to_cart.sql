{{
  config(
    materialized='table'
  )
}}

with add_to_cart_events as
(select *
from {{ref('stg_events')}}
where event_type = 'add_to_cart') ,

products as 
(select *
from {{ref('stg_products')}}),

user_first_cart_timestamp as
(select user_guid
    , min(first_event_timestamp) as first_cart_timestamp
from {{ref('int_user_first_event_timestamps')}}
where event_type = 'add_to_cart'
group by 1) 

select a.event_guid as add_to_cart_guid
    , a.user_guid
    , a.session_guid
    , a.product_guid
    , a.page_url
    , a.created_at_utc as add_to_cart_timestamp_utc
    , a.created_at_utc::date as add_to_cart_date_utc
    , case when b.first_cart_timestamp is not null then 1 else 0 end as first_cart_flag
    , c.product_name
    , c.product_type
    , c.price as product_price
    , case when d.session_guid is not null then 1 else 0 end as conversion_flag
from add_to_cart_events a
left join user_first_cart_timestamp b on a.user_guid = b.user_guid
                                        and a.created_at_utc = b.first_cart_timestamp
left join products c on a.product_guid = c.product_guid
left join {{ref('int_converted_sessions')}} d on a.session_guid = d.session_guid 

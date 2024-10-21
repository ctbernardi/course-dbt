{{
  config(
    materialized='table'
  )
}}

with events as 
(select *
from {{ref('stg_events')}}) ,

order_items as 
(select *
from {{ref('stg_order_items')}}),

products as 
(select *
from {{ref('stg_products')}})

select a.session_guid
    , a.user_guid
    , coalesce(a.product_guid,b.product_guid) as product_guid
    , c.session_start_time_utc
    , c.session_end_time_utc
    , d.product_name
    , d.product_type
    , count(distinct case when a.event_type = 'page_view' then a.event_guid else null end) as page_views
    , count(distinct case when a.event_type = 'add_to_cart' then a.event_guid else null end) as add_to_carts
    , count(distinct case when a.event_type = 'checkout' then a.event_guid else null end) as checkouts
    , count(distinct case when a.event_type = 'package_shipped' then a.event_guid else null end) as packages_shipped
    , datediff('minute',c.session_start_time_utc,c.session_end_time_utc) as session_length_minutes
from events a
left join order_items b on a.order_guid = b.order_guid
left join {{ref('int_session_timing')}} c on a.session_guid = c.session_guid    
left join products d on coalesce(a.product_guid,b.product_guid) = d.product_guid
group by 1,2,3,4,5,6,7
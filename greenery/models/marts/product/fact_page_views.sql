{{
  config(
    materialized='table'
  )
}}

with page_view_events as
(select *
from {{ref('stg_events')}}
where event_type = 'page_view') ,

products as 
(select *
from {{ref('stg_products')}}),

user_first_page_view_timestamp as
(select user_guid
    , min(first_event_timestamp) as first_page_view_timestamp
from {{ref('int_user_first_event_timestamps')}}
where event_type = 'page_view'
group by 1) 

select a.event_guid as page_view_guid
    , a.user_guid
    , a.session_guid
    , a.product_guid
    , a.page_url
    , a.created_at_utc as page_view_timestamp_utc
    , a.created_at_utc::date as page_view_date_utc
    , case when b.first_page_view_timestamp is not null then 1 else 0 end as first_page_view_flag
    , c.product_name
    , c.product_type
    , c.price as product_price
    , case when d.session_guid is not null then 1 else 0 end as conversion_flag
from page_view_events a
left join user_first_page_view_timestamp b on a.user_guid = b.user_guid
                                        and a.created_at_utc = b.first_page_view_timestamp
left join products c on a.product_guid = c.product_guid
left join {{ref('int_converted_sessions')}} d on a.session_guid = d.session_guid 

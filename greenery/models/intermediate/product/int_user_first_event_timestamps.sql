{{
  config(
    materialized='table'
  )
}}

select user_guid
    , event_type
    , min(created_at_utc) as first_event_timestamp
from {{ref('stg_events')}}
group by 1,2
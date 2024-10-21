{{
  config(
    materialized='table'
  )
}}

select session_guid
    , min(created_at_utc) as session_start_time_utc
    , max(created_at_utc) as session_end_time_utc
from {{ref('stg_events')}}
group by 1
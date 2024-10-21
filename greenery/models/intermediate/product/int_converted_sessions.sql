{{
  config(
    materialized='table'
  )
}}

select distinct session_guid
from {{ref('stg_events')}}
where event_type = 'checkout'
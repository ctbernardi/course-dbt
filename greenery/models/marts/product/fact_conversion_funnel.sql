{{
  config(
    materialized='table'
  )
}}

with events as 
(select *
from {{ref('stg_events')}}) 

select a.session_guid
    , {{ aggregate_distinct_counts('stg_events', 'event_type', 'session_guid') }}
from events a
group by 1
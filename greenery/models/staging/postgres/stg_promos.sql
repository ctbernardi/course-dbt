{{
  config(
    materialized='table'
  )
}}

SELECT 
    promo_id as promo_guid
    , discount
    , status   
FROM {{ source('postgres', 'promos') }}
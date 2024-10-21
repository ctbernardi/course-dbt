{{
  config(
    materialized='table'
  )
}}

SELECT 
    promo_id as promo_name
    , discount
    , status  as promo_status
FROM {{ source('postgres', 'promos') }}
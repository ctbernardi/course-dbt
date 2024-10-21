{{
  config(
    materialized='table'
  )
}}

SELECT 
    address_id AS address_guid,
    address,
    LPAD(CAST(zipcode AS VARCHAR), 5, '0') as zipcode,
    state,
    country,
FROM {{ source('postgres', 'addresses') }}
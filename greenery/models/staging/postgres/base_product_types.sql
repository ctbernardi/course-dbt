{{
  config(
    materialized='table'
  )
}}

select 1 as product_type_id
    , 'Discount' as product_type

union all

select 2 as product_type_id
    , 'Standard' as product_type

union all

select 3 as product_type_id
    , 'Luxury' as product_type
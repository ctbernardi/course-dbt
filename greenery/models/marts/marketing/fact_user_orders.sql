with users as

(select *
from {{ref('stg_users')}})

select a.user_guid
    , case when b.user_guid is not null then 1 else 0 end as buyer_flag
    , case when coalesce(b.num_orders,0) >= 2 then 1 else 0 end as repeat_buyer_flag
    , b.first_order_created_at_utc
    , b.last_order_created_at_utc
    , b.num_orders
    , coalesce(b.total_spend,0) as total_spend
    , coalesce(c.products_purchased,0) as products_purchased
from users a
left join {{ref('int_user_orders')}} b on a.user_guid = b.user_guid
left join {{ref('int_user_products_purchased')}} c on a.user_guid = c.user_guid

# Project 1 Submission - Caroline Bernardi

## How many users do we have? 
**Answer: 130 users**

```sql
  select count(distinct user_guid)
  from dev_db.dbt_ctbernardigmailcom.stg_users;
```
    

## On average, how many orders do we receive per hour?  
**Answer: 7.52 orders**

```sql
  select avg(orders)
  from (select date_trunc('hour',created_at_utc) as hour
          , count(*) as orders
        from dev_db.dbt_ctbernardigmailcom.stg_orders
        group by 1)
```
          

## On average, how long does an order take from being placed to being delivered?
**Answer: 3.89 days**

```sql
  select avg(days_to_delivery)
  from (select datediff('day',created_at_utc,delivered_at_utc) as days_to_delivery
        from dev_db.dbt_ctbernardigmailcom.stg_orders
         --  where status = 'delivered'
        )
```
        
## How many users have only made one purchase? Two purchases? Three+ purchases?

Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.

**Answer:**
| Purchases | Users |
|----------|----------|
| 1     | 25    |
| 2     | 28    |
| 3+    | 71    |

```sql
  select case when purchases < 3 then cast(purchases as string) else '3+' end as purchases
      , count(distinct user_guid) as users
  from (select user_guid
          , count(distinct order_guid) as purchases
      from dev_db.dbt_ctbernardigmailcom.stg_orders
      group by 1)
  group by 1
  order by 1
```

## On average, how many unique sessions do we have per hour?**
**Answer: 16.33**

```sql
  select avg(sessions) as avg_sessions_per_hour
  from (
      select date_trunc('hour',created_at_utc) as session_start_hour
          , count(distinct session_guid) as sessions
      from dev_db.dbt_ctbernardigmailcom.stg_events
      group by 1
      )
```
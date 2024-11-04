# Project 4 Submission - Caroline Bernardi

## Part 1. dbt Snapshots

### Which products had their inventory change from week 3 to week 4? 

```sql
 select name
    , week3_inventory
    , week4_inventory
    , week4_inventory - week3_inventory as WOW_change
from (select name
        , sum(case when dbt_valid_to::date = '2024-11-03' then inventory else 0 end) as week3_inventory
        , sum(case when dbt_valid_to is null then inventory else 0 end) as week4_inventory
    from dev_db.dbt_ctbernardigmailcom.inventory_snapshot
    group by 1)
order by 4 
;
```

| Plant                | Week 3  | Week 4  | WOW |
|----------------------|---------|---------|------------|
| Bamboo               | 44      | 23      | -21        |
| Monstera             | 50      | 31      | -19        |
| ZZ Plant             | 53      | 41      | -12        |
| String of pearls     | 0       | 10      | 10         |
| Philodendron         | 15      | 30      | 15         |
| Pothos               | 0       | 20      | 20         |
| Ficus                | 0       | 44      | 44         |
| Aloe Vera            | 0       | 47      | 47         |
| Snake Plant          | 0       | 48      | 48         |
| Birds Nest Fern      | 0       | 49      | 49         |
| Orchid               | 0       | 58      | 58         |
| Money Tree           | 0       | 59      | 59         |
| Angel Wings Begonia  | 0       | 65      | 65         |
| Spider Plant         | 0       | 67      | 67         |
| Dragon Tree          | 0       | 73      | 73         |
| Majesty Palm         | 0       | 74      | 74         |
| Boston Fern          | 0       | 77      | 77         |
| Cactus               | 0       | 81      | 81         |
| Fiddle Leaf Fig      | 0       | 82      | 82         |
| Alocasia Polly       | 0       | 83      | 83         |
| Pilea Peperomioides  | 0       | 85      | 85         |
| Devil's Ivy          | 0       | 88      | 88         |
| Rubber Plant         | 0       | 92      | 92         |
| Ponytail Palm        | 0       | 93      | 93         |
| Calathea Makoyana    | 0       | 94      | 94         |
| Jade Plant           | 0       | 94      | 94         |
| Pink Anthurium       | 0       | 95      | 95         |
| Bird of Paradise     | 0       | 97      | 97         |
| Peace Lily           | 0       | 99      | 99         |
| Arrow Head           | 0       | 100     | 100        |


### Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory? Did we have any items go out of stock in the last 3 weeks?   

Ficus, Aloe Vera and Snake Plant

       
## Part 2: Modeling Challenge

### Product Funnel

**How are our users moving through the product funnel?**

At first I thought my model fact_sessions was enough to answer the funnel questions. However, since the model is aggregated by session + user + product, it doesn't work since there are multiple lines per session.

Therefore, I created a new model, `fact_conversion_funnel`. This model used the macro I created `aggregate_distinct_counts`. It counts distinct `session_id` instead of `event_id` like `fact_sessions` does.

```sql
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
```

**Which steps in the funnel have largest drop off points?**

With my new model, it's easy to answer the conversion questions with this query:

```sql
select add_to_carts / page_views * 100 as add_to_cart_conversion
    , checkouts / add_to_carts * 100 as checkout_conversion
    , packages_shipped / checkouts * 100 as packages_shipped_conversions
from (select count(distinct session_guid) as sessions
        , sum(page_views) as page_views
        , sum(add_to_carts) as add_to_carts
        , sum(checkouts) as checkouts
        , sum(package_shippeds) as packages_shipped
    from dev_db.dbt_ctbernardigmailcom.fact_conversion_funnel)
```
| add_to_cart_conversion   | checkout_conversion   | packages_shipped_conversions   |
|-----------|-----------|-----------|
| 80.7958  | 77.3019  | 92.7978  |

**Use an exposure on your product analytics model to represent that this is being used in downstream BI tools**

In my product mart, I created an _exposures.yml file

```sql
version: 2

exposures:  
  - name: Product Funnel Dashboard
    description: >
      Models that are critical to our product funnel dashboard
    type: dashboard
    maturity: high
    owner:
      name: Caroline Bernardi
      email: ctbernardi@gmail.com
    depends_on:
      - ref('fact_conversion_funnel')
```

## Part 3: Reflection

### 3A. dbt next steps for you 

**What skills have you picked that give you the most confidence in pursuing this next step?**

Organization, documention, and don't repeat yourself!

### 3B. Setting up for production / scheduled dbt run of your project

In our current tech stack we use airflow, but we are converting to the data ecosystem of our parent company which usses Dagster
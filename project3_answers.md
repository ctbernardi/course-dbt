# Project 3 Submission - Caroline Bernardi

## Part 1. Conversion Rates

### What is our overall conversion rate?
**Answer: 62.5%**

I used two models I created in week 2 to answer these questions: `fact_sessions`, and `int_converted_sessions`

```sql
  select count(distinct b.session_guid) / count(distinct a.session_guid) as conversion_rate
  from dev_db.dbt_ctbernardigmailcom.fact_sessions a
  left join dev_db.dbt_ctbernardigmailcom.int_converted_sessions b on a.session_guid = b.session_guid
```

### What is our conversion rate by product?  

Again, I used `fact_sessions`, and `int_converted_sessions`. I included a field I made up called `product_type`, which groups the products into three categories based on price. It's interesting that the top three converting products are in the 'luxury' group (aka most expensive.) It might be that users who view these expensive plants have a higher intent to buy. If available, I'd look at product reviews for these plants as well.

```sql
  select product_name
    , product_type
    , count(distinct b.session_guid) / count(distinct a.session_guid) as conversion_rate
  from dev_db.dbt_ctbernardigmailcom.fact_sessions a
  left join dev_db.dbt_ctbernardigmailcom.int_converted_sessions b on a.session_guid = b.session_guid
  group by 1,2
  order by 3 desc;
```

| Product              | Product Type | Conversion |
|----------------------|----------|------------|
| Fiddle Leaf Fig      | Luxury   | 0.892857   |
| String of pearls     | Luxury   | 0.890625   |
| Monstera             | Luxury   | 0.877551   |
| ZZ Plant             | Standard | 0.873016   |
| Cactus               | Discount | 0.854545   |
| Bamboo               | Discount | 0.835821   |
| Spider Plant         | Discount | 0.830508   |
| Calathea Makoyana    | Standard | 0.830189   |
| Majesty Palm         | Luxury   | 0.820896   |
| Arrow Head           | Standard | 0.793651   |
| Dragon Tree          | Luxury   | 0.790323   |
| Ponytail Palm        | Luxury   | 0.785714   |
| Money Tree           | Standard | 0.785714   |
| Rubber Plant         | Standard | 0.777778   |
| Snake Plant          | Standard | 0.767123   |
| Devil's Ivy          | Discount | 0.755556   |
| Bird of Paradise     | Luxury   | 0.750000   |
| Pilea Peperomioides  | Standard | 0.745763   |
| Philodendron         | Standard | 0.741935   |
| Pothos               | Standard | 0.737705   |
| Angel Wings Begonia  | Luxury   | 0.737705   |
| Orchid               | Luxury   | 0.733333   |
| Birds Nest Fern      | Discount | 0.730769   |
| Pink Anthurium       | Luxury   | 0.729730   |
| Peace Lily           | Luxury   | 0.727273   |
| Ficus                | Standard | 0.720588   |
| Boston Fern          | Standard | 0.714286   |
| Jade Plant           | Discount | 0.695652   |
| Alocasia Polly       | Luxury   | 0.666667   |
| Aloe Vera            | Discount | 0.661538   |

       
## Part 2: Macros

### Create a macro to simplify part of a model(s)

**aggregate_distinct_counts:**

I created the following macro to aggregate distinct counts of a chosen field. For my `fact_sessions` model I used it to aggregate counts by `event_type`. 

```sql
{% macro aggregate_distinct_counts(table_name, filter_column, count_column) %}
  {% set distinct_values = dbt_utils.get_column_values(
    table=ref(table_name), 
    column=filter_column
  ) %}

  {% for value in distinct_values %}
    count(distinct case when {{ filter_column }} = '{{ value }}' then {{ count_column }} else null end) as {{ value }}s
    {% if not loop.last %},{% endif %}
  {% endfor %}
{% endmacro %}
```

Here's how it is used in my model:

```sql
  select a.session_guid
      , a.user_guid
      , coalesce(a.product_guid,b.product_guid) as product_guid
      , c.session_start_time_utc
      , c.session_end_time_utc
      , d.product_name
      , d.product_type
      , {{ aggregate_distinct_counts('stg_events', 'event_type', 'event_guid') }}
      , datediff('minute',c.session_start_time_utc,c.session_end_time_utc) as session_length_minutes
  from events a
  left join order_items b on a.order_guid = b.order_guid
  left join {{ref('int_session_timing')}} c on a.session_guid = c.session_guid    
  left join products d on coalesce(a.product_guid,b.product_guid) = d.product_guid
  group by 1,2,3,4,5,6,7
```

## Part 3: Hooks

### Add a post hook to your project to apply grants to the role “reporting”

First I created the 'grant' macro

```sql
{% macro grant(role) %}

    {% set sql %}
      GRANT USAGE ON SCHEMA {{ schema }} TO ROLE {{ role }};
      GRANT SELECT ON {{ this }} TO ROLE {{ role }};
    {% endset %}

    {% set table = run_query(sql) %}

{% endmacro %}
```

Then, in `dbt_project.yml` I added the following post_hook

```sql
models:
  greenery:
     +post-hook:
      - "{{ grant(role='reporting') }}"
```

I can see the grant worked in the snowflake UI:

<img width="717" alt="grant_success" src="https://github.com/user-attachments/assets/8b3e2334-273e-44ae-92d4-4441060c07bf">

## Part 4: Packages

### Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project

I have `dbt_utils` installed and it is used in the `aggregate_distinct_counts` macro in Part 3

## Part 5: DAG

<img width="690" alt="Week 3 DAG" src="https://github.com/user-attachments/assets/19619764-e9cc-49da-a5c4-7e94fb1c7e65">

## Part 6: Snapshots

### Which products had their inventory change from week 2 to week 3?

```sql
select name
    , week2_inventory
    , week3_inventory
    , week3_inventory - week2_inventory as WOW_change
from (select name
        , sum(case when dbt_valid_to::date = '2024-10-27' then inventory else 0 end) as week2_inventory
        , sum(case when dbt_valid_to is null then inventory else 0 end) as week3_inventory
    from dev_db.dbt_ctbernardigmailcom.inventory_snapshot
    group by 1)
order by 4
```

| Product              | Week2 | Week 3 | Difference |
|----------------------|---------|---------|------------|
| ZZ Plant             | 89      | 53      | -36        |
| Pothos               | 20      | 0       | -20        |
| Monstera             | 64      | 50      | -14        |
| Bamboo               | 56      | 44      | -12        |
| String of pearls     | 10      | 0       | -10        |
| Philodendron         | 25      | 15      | -10        |
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
| Cactus            


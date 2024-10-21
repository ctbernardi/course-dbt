# Project 2 Submission - Caroline Bernardi

## Part 1. Models

### What is our user repeat rate? 
**Answer: 79.8%**

```sql
  select sum(repeat_buyer_flag) / sum(buyer_flag) as user_repeat_rate
  from dev_db.dbt_ctbernardigmailcom.fact_user_orders;
```
    

### What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?  
To determine if a user is likely to purchase again I would look at their past order behavior such as number of orders, number of products purchased, and total amount spent. I woiuld also look at user behavior on the website like the number of page views, number of sessions, and time spent on the site. If a user purchased with a promo or discount they are probably less likely to purchase again. I would also be interested in looking at a user's engagement with other marketing materials such as emails as well as ratings or reviews on the website.

          
### More stakeholders are coming to us for data, which is great! But we need to get some more models created before we can help. Create a marts folder, so we can organize our models, with the following subfolders for business units:
**Product:**
fact_add_to_cart, fact_page_views, fact_sessions

**Core:**
fact_orders

**Marketing:**
fact_user_orders
        
### Explain the product mart models you added. Why did you organize the models in the way you did?

**Product:**

> **fact_page_views:**
    The first model I created was a closer look at all 'page_view' event_types. I think of this as the 'top of the funnel' in the conversion process. The grain here is the event_id or actual page_view. This model utilizes an intermediate model I created to create a first_page_view_flag. It joins to the products staging table to understand what product is being looked at. It also uses an intermediate model to determine if the page view eventually resulted in a conversion (if the same session resulted in a checkout.) 


> **fact_add_to_cart:**
    This model is very similar to fact_page_views except that it focuses on the 'add_to_cart' event_type.


> **fact_sessions:**
    The grain of this model is the session_id instead of the event_id. It aggregates all events for a single session. It utilize an intermediate model called 'session timing' to figure out how long the session was in minutes. It also joins to the product staging table.

**Note:**
I created a new base table product_types just to try and understand how base tables could be used. I'm not sure the best place to keep these in my repo though. I did not created models for the event_types 'checkout' and 'package shipped' because most of that info is in the actual orders. However, I may add them later in the project if I come across a need. 

**Core:**

> **fact_orders:**
    Core model for all orders with individual orders as the grain. Relies on the intermediate model products_in_order.

**Marketing:**

> **fact_user_orders:**
    Similar to the fact_orders table but it's aggregated at the user level. Relies on the intermediate models user_products_purchased and user_orders.

### Use the dbt docs to visualize your model DAGs to ensure the model layers make sense
The Intermediate and Mart layers get a little convoluted... but I think that is okay. I don't have any dimension models in my marts yet, but will probably need to add them eventually.
![<img width="904" alt="Screen Shot 2024-10-20 at 8 55 34 PM" src="https://github.com/user-attachments/assets/26a5146c-2d9c-4087-afa7-0c73618a3aa6">

## Part 2: Tests

### What assumptions are you making about each model? (i.e. why are you adding each test?)

I would like to add more tests than just the ones below,  but ran out of time this week.

**Addresses:**

> address_guid not null and unique
> zipcode not null and 5 digits (had to create the 5 digits test as a macro)

**Events:**

> event_guid not null and unique
> user_guid exists in stg_users

**Order Items:**

> order_guid not null 
> product_guid not null

**Orders:**

> order_guid not null and unique

**Products:**

> product_guid not null and unique

**Users:**

> user_guid not null and unique

### Did you find any “bad” data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?

Not all of the zipcodes passed the 5 digit test, so I added a leading 0 in the staging model for addresses to the zipcodes that were only 4 digits.

### Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.

I would send the results of the tests in a slack channel alert if they are not empty. For example, the results of this code could be sent to catch the zipcode error I mentioned:

```sql
  select * 
  from dev_db.dbt_ctbernardigmailcom_dbt_test__audit.five_digits_stg_addresses_zipcode
```

## Part 3: dbt Snapshots

### Run the product snapshot model using dbt snapshot and query it in snowflake to see how the data has changed since last week

I had an error in my snapshot code last week, so this was my first snapshot. I will check it again next week using this code:

```sql
  select *
  from dev_db.dbt_ctbernardigmailcom.inventory_snapshot
```
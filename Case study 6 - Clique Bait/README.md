# Case Study #6: Clique Bait 

## 📕 Table of Contents  
- 🔐 [Entity Relationship Diagram](#-entity-relationship-diagram)  
- ❓ [Case Study Questions](#-case-study-questions)
  - [1. Digital Analysis](#1-digital-analysis)
  - [2. Product Funnel Analysis](#2-product-funnel-analysis)
  - [3. Campaigns Analysis](#3-campaigns-analysis)
- [🚀 My Solution](#-my-solution)

---

### 🔐 Entity Relationship Diagram  

Using the DDL schema details to create an ERD for all the Clique Bait datasets.

<img width="911" height="655" alt="Screenshot 2025-10-02 at 16 03 01" src="https://github.com/user-attachments/assets/b51dcabb-d4f6-4677-b8a6-7dc724b2abd1" />

- Table: `event_identifier`
  
| event_type | event_name    |
|------------|---------------|
| 1          | Page View     |
| 2          | Add to Cart   |
| 3          | Purchase      |
| 4          | Ad Impression |
| 5          | Ad Click      |

- Table: `users`

| user_id | cookie_id | start_date          |
|---------|-----------|---------------------|
| 1       | c4ca42    | 2020-02-04 00:00:00 |
| 2       | c81e72    | 2020-01-18 00:00:00 |
| 3       | eccbc8    | 2020-02-21 00:00:00 |
| 4       | a87ff6    | 2020-02-22 00:00:00 |
| 5       | e4da3b    | 2020-02-01 00:00:00 |
| 6       | 167909    | 2020-01-25 00:00:00 |
| 7       | 8f14e4    | 2020-02-09 00:00:00 |

- Table: `campaign_identifier`

| campaign_id | products | campaign_name                     | start_date          | end_date            |
|-------------|----------|-----------------------------------|---------------------|---------------------|
| 1           | 1–3      | BOGOF – Fishing For Compliments   | 2020-01-01 00:00:00 | 2020-01-14 00:00:00 |
| 2           | 4–5      | 25% Off – Living The Lux Life     | 2020-01-15 00:00:00 | 2020-01-28 00:00:00 |
| 3           | 6–8      | Half Off – Treat Your Shellf(ish) | 2020-02-01 00:00:00 | 2020-03-31 00:00:00 |

- Table: `events`

| visit_id | cookie_id | page_id | event_type | sequence_number | event_time                |
|----------|-----------|---------|------------|-----------------|---------------------------|
| ccf365   | c4ca42    | 1       | 1          | 1               | 2020-02-04 19:16:09.182546 |
| ccf365   | c4ca42    | 2       | 1          | 2               | 2020-02-04 19:16:17.358191 |
| ccf365   | c4ca42    | 6       | 1          | 3               | 2020-02-04 19:16:58.454669 |
| ccf365   | c4ca42    | 9       | 1          | 4               | 2020-02-04 19:16:58.609142 |
| ccf365   | c4ca42    | 9       | 2          | 5               | 2020-02-04 19:17:51.729420 |
| ccf365   | c4ca42    | 10      | 1          | 6               | 2020-02-04 19:18:11.605815 |
| ccf365   | c4ca42    | 10      | 2          | 7               | 2020-02-04 19:19:10.570786 |
| ccf365   | c4ca42    | 11      | 1          | 8               | 2020-02-04 19:19:46.911728 |

- Table: `page_hierarchy`

| page_id | page_name     | product_category | product_id |
|---------|---------------|------------------|------------|
| 1       | Home Page     | NULL             | NULL       |
| 2       | All Products  | NULL             | NULL       |
| 3       | Salmon        | Fish             | 1          |
| 4       | Kingfish      | Fish             | 2          |
| 5       | Tuna          | Fish             | 3          |
| 6       | Russian Caviar| Luxury           | 4          |
| 7       | Black Truffle | Luxury           | 5          |
| 8       | Abalone       | Shellfish        | 6          |
| 9       | Lobster       | Shellfish        | 7          |
| 10      | Crab          | Shellfish        | 8          |
| 11      | Oyster        | Shellfish        | 9          |
| 12      | Checkout      | NULL             | NULL       |
| 13      | Confirmation  | NULL             | NULL       |


### ❓ Case Study Questions

### 1. Digital Analysis

📄 [View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%206%20-%20Clique%20Bait/Solution/2.%20Digital%20Analysis.md)

Using the available datasets - answer the following questions using a single query for each one:

- How many users are there?
- How many cookies does each user have on average?
- What is the unique number of visits by all users per month?
- What is the number of events for each event type?
- What is the percentage of visits which have a purchase event?
- What is the percentage of visits which view the checkout page but do not have a purchase event?
- What are the top 3 pages by number of views?
- What is the number of views and cart adds for each product category?
- What are the top 3 products by purchases?

### 2. Product Funnel Analysis

📄 [View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%206%20-%20Clique%20Bait/Solution/3.%20Product%20Funnel%20Analysis.md)

Using a single SQL query - create a new output table which has the following details:

- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?
- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:

- Which product had the most views, cart adds and purchases?
- Which product was most likely to be abandoned?
- Which product had the highest view to purchase percentage?
- What is the average conversion rate from view to cart add?
- What is the average conversion rate from cart add to purchase?

### 3. Campaigns Analysis

📄 [View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%206%20-%20Clique%20Bait/Solution/4.%20Campaigns%20Analysis.md)

Generate a table that has 1 single row for every unique visit_id record and has the following columns:

- `user_id`
- `visit_id`
- `visit_start_time`: the earliest event_time for each visit
- `page_views`: count of page views for each visit
- `cart_adds`: count of product cart add events for each visit
- `purchase`: 1/0 flag if a purchase event exists for each visit
- `campaign_name`: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- `impression`: count of ad impressions for each visit
- `click`: count of ad clicks for each visit
- (Optional column) `cart_products`: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to eachother?












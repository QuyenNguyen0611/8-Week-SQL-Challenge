# 🥑 Case Study #3: Foodie-Fi

## B. Data Analysis Questions

### Question 1: How many customers has Foodie-Fi ever had?
```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers 
FROM subscriptions;
```

|total_customers|
|---------------|
|1000           |

### Question 2:  What is the monthly distribution of trial plan start_date values for our dataset? - use the start of the month as the group by value
```sql
SELECT
MONTHNAME(start_date) AS MONTH,
COUNT(DISTINCT customer_id) AS count_customers
FROM subscriptions 
WHERE plan_id = 0
GROUP BY MONTH
ORDER BY count_customers DESC;
```

| Month     | Count of Customers |
|-----------|--------------------|
| March     | 94                 |
| July      | 89                 |
| August    | 88                 |
| January   | 88                 |
| May       | 88                 |
| September | 87                 |
| December  | 84                 |
| April     | 81                 |
| June      | 79                 |
| October   | 79                 |
| November  | 75                 |
| February  | 68                 |

### Question 3: What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
```sql
SELECT 
plan_name, 
COUNT(DISTINCT customer_id) AS count
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE start_date >= '2021-01-01'
GROUP BY plan_name
ORDER BY count;
```

| Plan Name      | Count |
|----------------|-------|
| Basic Monthly  | 8     |
| Pro Monthly    | 60    |
| Pro Annual     | 63    |
| Churn          | 71    |

We can see that most customers churned, while Pro plans were popular and Basic Monthly had the fewest signups.

### Question 4:  What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```sql
SELECT
COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) AS churn_customers,
ROUND(COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) *100
/ COUNT(DISTINCT customer_id),1) AS churn_percentage
FROM subscriptions;
```
|churn_customers| churn_percentage|
|---------------|-----------------|
|307            |30.7             |

### Question 5: How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
- For each `customer_id`, assign a row number using `ROW_NUMBER()` ordered by their subscription history.
- This helps track the sequence of plan changes per customer (e.g., first plan = `row_id` = 1, second plan = `row_id` = 2).
- Count customers whose second plan (`row_id` = 2) is a churn (`plan_id` = 4). These are customers who churned right after their first plan.
```sql
WITH rank_cte AS(
SELECT 
customer_id, plan_id, 
ROW_NUMBER() OVER (PARTITION BY customer_id) AS row_id
FROM subscriptions)

SELECT
COUNT(DISTINCT CASE WHEN plan_id = 4 AND row_id = 2 THEN customer_id END) AS churn_customers,
ROUND(COUNT(DISTINCT CASE WHEN plan_id = 4 AND row_id = 2 THEN customer_id END)*100 / COUNT(DISTINCT customer_id), 0) AS percentage
FROM rank_cte;
```
|churn_customers| percentage|
|---------------|-----------|
|92             | 9         |

### Question 6: What is the number and percentage of customer plans after their initial free trial?

```sql
WITH rank_cte AS(
SELECT customer_id, plan_id, 
LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan_id
FROM subscriptions)

SELECT
next_plan_id AS plan_id,
COUNT(customer_id) AS number_of_customers,
ROUND(COUNT(customer_id)*100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage
FROM rank_cte
WHERE next_plan_id IS NOT NULL
AND plan_id = 0
GROUP BY next_plan_id
ORDER BY next_plan_id;
```

| plan_id | number_of_customers | percentage |
|---------|---------------------|------------|
| 1       | 546                 | 54.6       |
| 2       | 325                 | 32.5       |
| 3       | 37                  | 3.7        |
| 4       | 92                  | 9.2        |

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

### Question 7: What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
- Joins the `subscriptions` and `plans` tables to get the `plan_name` for each subscription.
- Filters to include only subscriptions with a `start_date` on or before Dec 31, 2020.
- Uses the `LEAD()` window function to find each customer's next subscription date (if any), based on chronological order.
```sql
SELECT 
s.plan_id,
p.plan_name,
s.customer_id, 
LEAD (s.start_date) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_date
FROM plans p 
JOIN subscriptions s 
ON p.plan_id = s.plan_id
WHERE s.start_date <= '2020-12-31';
```

| plan_id | plan_name      | customer_id | next_date   |
|---------|----------------|-------------|-------------|
| 0       | Trial          | 1           | 2020-08-08  |
| 1       | Basic Monthly  | 1           | NULL        |
| 0       | Trial          | 2           | 2020-09-27  |
| 3       | Pro Annual     | 2           | NULL        |
| 0       | Trial          | 3           | 2020-01-20  |
| 1       | Basic Monthly  | 3           | NULL        |
| 0       | Trial          | 4           | 2020-01-24  |
|...      |...             | ...         |...          |

- Identify customers whose last recorded plan before 2021 had no subsequent plan.
- Counts these customers per plan and computes what percentage of all customers had that plan as their last plan before 2021.
 
```sql
WITH next_dates AS (
SELECT 
s.plan_id,
p.plan_name,
s.customer_id, 
LEAD (s.start_date) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_date
FROM plans p 
JOIN subscriptions s 
ON p.plan_id = s.plan_id
WHERE s.start_date <= '2020-12-31')

SELECT 
plan_id,
plan_name,
COUNT(DISTINCT CASE WHEN next_date IS NULL THEN customer_id END) AS customer_count,
ROUND(COUNT(DISTINCT CASE WHEN next_date IS NULL THEN customer_id END)*100/ 
(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS percentage
FROM next_dates
GROUP BY plan_id, plan_name
ORDER BY plan_id;
```

| Plan ID | Plan Name      | Customer Count | Percentage |
|---------|----------------|----------------|------------|
| 0       | Trial          | 19             | 1.9        |
| 1       | Basic Monthly  | 224            | 22.4       |
| 2       | Pro Monthly    | 326            | 32.6       |
| 3       | Pro Annual     | 195            | 19.5       |
| 4       | Churn          | 236            | 23.6       |

### Question 8: How many customers have upgraded to an annual plan in 2020?

```sql
SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions
WHERE plan_id = 3
AND YEAR(start_date) = 2020;
```

|number_of_customers|
|-------------------|
|195                |

### Question 9: How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
WITH trial_plan AS (
-- Filter results to include only the customers subscribed to the trial plan
SELECT
customer_id, 
start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0)
, 
annual_plan AS (
-- Filter results to include only the customers subscribed to the pro annual plan
SELECT 
customer_id, 
start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3)

SELECT
ROUND(AVG(DATEDIFF(annual_date, trial_date)),0) AS days_to_upgrade
FROM trial_plan t
JOIN annual_plan a 
ON t.customer_id = a.customer_id;
```
|days_to_upgrade|
|---------------|
|105            |

### Question 10: Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
- Computes the number of days between when the customer started the trial and when they subscribed to the annual plan.
- Divides the day difference by 30 to convert to months.
- Uses `FLOOR()` to round down (e.g., 59 days → 1 month).
- Adds +1 so that even upgrades within the first month fall into bin 1.
  
```sql
WITH trial_plan AS (
-- Filter results to include only the customers subscribed to the trial plan
SELECT
customer_id, 
start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0),
 
annual_plan AS (
-- Filter results to include only the customers subscribed to the tpro annual plan
SELECT
customer_id, 
start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3)
, 

bins AS (
SELECT 
FLOOR(DATEDIFF(annual.annual_date, trial.trial_date) / 30) + 1 AS avg_days_to_upgrade
FROM trial_plan AS trial
JOIN annual_plan AS annual
ON trial.customer_id = annual.customer_id
)

SELECT
CONCAT((avg_days_to_upgrade - 1) * 30, ' - ', avg_days_to_upgrade * 30, ' days') AS bucket,
COUNT(*) as num_of_customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
```

| bucket          | num_of_customers    |
|-----------------|---------------------|
| 0 – 30 days     | 48                  |
| 30 – 60 days    | 25                  |
| 60 – 90 days    | 33                  |
| 90 – 120 days   | 35                  |
| 120 – 150 days  | 43                  |
| 150 – 180 days  | 35                  |
| 180 – 210 days  | 27                  |
| 210 – 240 days  | 4                   |
| 240 – 270 days  | 5                   |
| 270 – 300 days  | 1                   |
| 300 – 330 days  | 1                   |
| 330 – 360 days  | 1                   |

### Question 11: How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
- Performs a self-join on the `subscriptions` table to compare multiple plans for the same customer.
- Ensures the Basic Monthly plan began after the Pro Monthly plan, confirming it was a true downgrade in subscription level.

```sql
SELECT
COUNT(DISTINCT p.customer_id) AS customers_downgraded
FROM subscriptions p
JOIN subscriptions b
ON p.customer_id = b.customer_id
WHERE p.plan_id = 2  
AND b.plan_id = 1  
AND YEAR(p.start_date) = 2020
AND YEAR(b.start_date) = 2020
AND b.start_date > p.start_date;
```

|customers_downgraded|
|--------------------|
|0                   |



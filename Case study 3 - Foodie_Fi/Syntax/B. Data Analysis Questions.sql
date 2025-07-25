# 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customers 
FROM subscriptions; 

# 2. What is the monthly distribution of trial plan start_date values for our dataset? - use the start of the month as the group by value
SELECT
MONTHNAME(start_date) AS MONTH,
COUNT(DISTINCT customer_id) AS count_customers
FROM subscriptions 
WHERE plan_id = 0
GROUP BY MONTH;

# 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT 
plan_name, 
COUNT(DISTINCT customer_id) AS count
FROM subscriptions s
JOIN plans p
ON s.plan_id = p.plan_id
WHERE start_date >= '2021-01-01'
GROUP BY plan_name
ORDER BY count;

# 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) AS churn_customers,
ROUND(COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) *100 / COUNT(DISTINCT customer_id),1) AS churn_percentage
FROM subscriptions;

# 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH rank_cte AS(
SELECT 
customer_id, plan_id, 
ROW_NUMBER() OVER (PARTITION BY customer_id) AS row_id
FROM subscriptions)

SELECT
COUNT(DISTINCT CASE WHEN plan_id = 4 AND row_id = 2 THEN customer_id END) AS churn_customers,
ROUND(COUNT(DISTINCT CASE WHEN plan_id = 4 AND row_id = 2 THEN customer_id END)*100 / COUNT(DISTINCT customer_id), 0) AS percentage
FROM rank_cte;

# 6. What is the number and percentage of customer plans after their initial free trial?
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

# 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
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

# 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS number_of_customers
FROM subscriptions
WHERE plan_id = 3
AND YEAR(start_date) = 2020;

# 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plan AS (
-- Filter results to include only the customers subscribed to the trial plan
SELECT
customer_id, 
start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0)
, 
annual_plan AS (
-- Filter results to include only the customers subscribed to the tpro annual plan
SELECT 
customer_id, 
start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3)

SELECT
ROUND(AVG(DATEDIFF(annual_date, trial_date)),0) AS days_to_upgrade
FROM trial_plan t
JOIN annual_plan a 
ON t.customer_id = a.customer_id

# 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
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

# 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
SELECT
COUNT(DISTINCT p.customer_id) AS customers_downgraded
FROM subscriptions p
JOIN subscriptions b
ON p.customer_id = b.customer_id
WHERE p.plan_id = 2  -- pro monthly
AND b.plan_id = 1  -- basic monthly
AND YEAR(p.start_date) = 2020
AND YEAR(b.start_date) = 2020
AND b.start_date > p.start_date;


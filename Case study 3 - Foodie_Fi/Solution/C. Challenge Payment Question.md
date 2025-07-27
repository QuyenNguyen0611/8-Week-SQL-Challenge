# 🥑 Case Study #3: Foodie-Fi

## Challenge Payment Question

The Foodie-Fi team has asked us to generate a payments_2020 table based on the subscriptions made during 2020, with the following conditions:

**Payment Rules:**
- Monthly plans are billed on the same day of the month as their start_date.
- Upgrades from Basic to Pro (Monthly or Annual) start immediately and are charged the price difference for that month.
- Upgrades from Pro Monthly to Pro Annual are billed at the end of the current billing period and start afterward.
- Churned customers stop making payments immediately after churning.

## Step-by-Step Approach
1. Filter 2020 Subscriptions (excluding trial & churn)
2. Join `plans` table to get `plan_name` and `price`
3. Remove trial and churn plans
4. Uses `LEAD()` to get the start date of the next plan (to define a billing cutoff)

```sql
SELECT 
customer_id, 
p.plan_id, 
plan_name, 
start_date,
LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date, s.plan_id) AS cutoff_date,
price AS amount
FROM plans p 
JOIN subscriptions s ON p.plan_id = s.plan_id 
WHERE YEAR(start_date) = 2020
AND s.plan_id NOT IN (0, 4);
```

| customer_id | plan_id | plan_name      | start_date  | cutoff_date | amount |
|-------------|---------|----------------|-------------|-------------|--------|
| 1           | 1       | basic monthly  | 2020-08-08  | NULL        | 9.9    |
| 2           | 3       | pro annual     | 2020-09-27  | NULL        | 199    |
| 3           | 1       | basic monthly  | 2020-01-20  | NULL        | 9.9    |
| 4           | 1       | basic monthly  | 2020-01-24  | NULL        | 9.9    |
| 5           | 1       | basic monthly  | 2020-08-10  | NULL        | 9.9    |
| 6           | 1       | basic monthly  | 2020-12-30  | NULL        | 9.9    |
| 7           | 1       | basic monthly  | 2020-02-12  | 2020-05-22  | 9.9    |
| 7           | 2       | pro monthly    | 2020-05-22  | NULL        | 19.9   |
|...          |...      |...             |...          |...          |...     |

5. The cutoff_date column contains NULL values for customers who had no subsequent plan in 2020, meaning it was their final plan of the year. To handle this, we replace all NULL values with '2020-12-31'.

 ```sql
WITH cte AS (
SELECT 
customer_id, 
p.plan_id, 
plan_name, 
start_date,
LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date, s.plan_id) AS cutoff_date,
price AS amount
FROM plans p 
JOIN subscriptions s ON p.plan_id = s.plan_id 
WHERE YEAR(start_date) = 2020
AND s.plan_id NOT IN (0, 4)
),

cte1 AS (
SELECT 
customer_id, 
plan_id, 
plan_name, 
start_date, 
COALESCE(cutoff_date, '2020-12-31') AS cutoff_date, 
amount
FROM cte
)

SELECT * FROM cte1;
```

| customer_id | plan_id | plan_name      | start_date  | cutoff_date | amount |
|-------------|---------|----------------|-------------|-------------|--------|
| 1           | 1       | basic monthly  | 2020-08-08  | 2020-12-31  | 9.9    |
| 2           | 3       | pro annual     | 2020-09-27  | 2020-12-31  | 199    |
| 3           | 1       | basic monthly  | 2020-01-20  | 2020-12-31  | 9.9    |
| 4           | 1       | basic monthly  | 2020-01-24  | 2020-12-31  | 9.9    |
| 5           | 1       | basic monthly  | 2020-08-10  | 2020-12-31  | 9.9    |
| 6           | 1       | basic monthly  | 2020-12-30  | 2020-12-31  | 9.9    |
| 7           | 1       | basic monthly  | 2020-02-12  | 2020-05-22  | 9.9    |
| 7           | 2       | pro monthly    | 2020-05-22  | 2020-12-31  | 19.9   |
|...          |...      |...             |....         |...          |...     |

For users on the Basic or Pro Monthly plans, the number of months between start_date and cutoff_date determines how many subscription payments they made. 
In contrast, users on the Pro Annual plan are charged only once for the entire year.

6. Therefore, we use a recursive CTE to generate additional rows for users on monthly plans by incrementing the `start_date` by one month at a time, continuing until the start_date exceeds the `cutoff_date`.

```sql
WITH RECURSIVE cte AS (
SELECT 
customer_id, 
p.plan_id, 
plan_name, 
start_date,
LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date, s.plan_id) AS cutoff_date,
price AS amount
FROM plans p 
JOIN subscriptions s ON p.plan_id = s.plan_id 
WHERE YEAR(start_date) = 2020
AND s.plan_id NOT IN (0, 4)
),

cte1 AS (
SELECT 
customer_id, 
plan_id, 
plan_name, 
start_date, 
COALESCE(cutoff_date, '2020-12-31') AS cutoff_date, 
amount
FROM cte
),

cte2 AS (
-- Anchor member
SELECT 
customer_id, 
plan_id, 
plan_name, 
start_date, 
cutoff_date, 
amount 
FROM cte1

UNION ALL

-- Recursive member
SELECT 
customer_id, 
plan_id, 
plan_name, 
DATE_ADD(start_date, INTERVAL 1 MONTH), 
cutoff_date, 
amount 
FROM cte2
WHERE cutoff_date > DATE_ADD(start_date, INTERVAL 1 MONTH)
AND plan_name <> 'pro annual'
)

SELECT * FROM cte2
ORDER BY customer_id;
```

| customer_id | plan_id | plan_name      | start_date  | cutoff_date | amount |
|-------------|---------|----------------|-------------|-------------|--------|
| ...         |...      | ...            | ...         | ...         | ...    |
| 15          | 2       | pro monthly    | 2020-08-24  | 2020-12-31  | 19.9   |
| 15          | 2       | pro monthly    | 2020-09-24  | 2020-12-31  | 19.9   |
| 15          | 2       | pro monthly    | 2020-10-24  | 2020-12-31  | 19.9   |
| 15          | 2       | pro monthly    | 2020-11-24  | 2020-12-31  | 19.9   |
| 15          | 2       | pro monthly    | 2020-12-24  | 2020-12-31  | 19.9   |
| 16          | 1       | basic monthly  | 2020-06-07  | 2020-12-31  | 9.9    |
| 16          | 3       | pro annual     | 2020-10-21  | 2020-12-31  | 199    |
| 16          | 1       | basic monthly  | 2020-07-07  | 2020-10-21  | 9.9    |
| 16          | 1       | basic monthly  | 2020-08-07  | 2020-10-21  | 9.9    |
| 16          | 1       | basic monthly  | 2020-09-07  | 2020-10-21  | 9.9    |
| ...         |...      | ...            | ...         | ...         | ...    |

When a customer upgrades from a Basic plan to a Pro (Monthly or Annual) plan within the same billing cycle, the Pro plan charge is reduced by the amount already paid for the Basic plan. 

7. To implement this, we subtract the Basic plan's cost from the Pro plan's price when such an upgrade occurs.
8. We use a `RANK()` function to assign the payment order for each customer based on their `start_date`.
9. We would copy the result of our query to a table called `payments_2020`

```sql
DROP TABLE IF EXISTS payments_2020;
CREATE TABLE payments_2020 AS
WITH RECURSIVE cte AS (
SELECT 
customer_id, 
p.plan_id, 
plan_name, 
start_date,
LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date, s.plan_id) AS cutoff_date,
price AS amount
FROM plans p 
JOIN subscriptions s ON p.plan_id = s.plan_id 
WHERE YEAR(start_date) = 2020
AND s.plan_id NOT IN (0, 4)
),

cte1 AS (
SELECT 
customer_id, 
plan_id, 
plan_name, 
start_date, 
COALESCE(cutoff_date, '2020-12-31') AS cutoff_date, 
amount
FROM cte
),

cte2 AS (
-- Anchor member
SELECT 
customer_id, 
plan_id, 
plan_name, 
start_date, 
cutoff_date, 
amount 
FROM cte1

UNION ALL

-- Recursive member
SELECT 
customer_id, 
plan_id, 
plan_name, 
DATE_ADD(start_date, INTERVAL 1 MONTH), 
cutoff_date, 
amount 
FROM cte2
WHERE cutoff_date > DATE_ADD(start_date, INTERVAL 1 MONTH)
AND plan_name <> 'pro annual'
),

cte3 AS (
SELECT 
customer_id, 
plan_id, 
plan_name, 
start_date AS payment_date, 
amount,
LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS last_payment_plan,
LAG(amount) OVER(PARTITION BY customer_id ORDER BY start_date) AS last_amount_paid,
RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS payment_order
FROM cte2
)

SELECT 
customer_id, 
plan_id, 
plan_name, 
payment_date, 
ROUND(CASE 
WHEN plan_id IN (2, 3) AND last_payment_plan = 1 THEN amount - last_amount_paid
ELSE amount
END,2) AS amount, 
payment_order
FROM cte3
ORDER BY customer_id, payment_date;
```

```sql
SELECT * FROM payments_2020;
```

| Customer ID | Plan ID | Plan Name      | Payment Date | Amount | Payment Order |
|-------------|---------|----------------|--------------|--------|---------------|
|...          |...      |...             |...           |...     |...            |
| 7           | 2       | pro monthly    | 2020-07-22   | 19.9   | 7             |
| 7           | 2       | pro monthly    | 2020-08-22   | 19.9   | 8             |
| 7           | 2       | pro monthly    | 2020-09-22   | 19.9   | 9             |
| 7           | 2       | pro monthly    | 2020-10-22   | 19.9   | 10            |
| 7           | 2       | pro monthly    | 2020-11-22   | 19.9   | 11            |
| 7           | 2       | pro monthly    | 2020-12-22   | 19.9   | 12            |
| 8           | 1       | basic monthly  | 2020-06-18   | 9.9    | 1             |
| 8           | 1       | basic monthly  | 2020-07-18   | 9.9    | 2             |
| 8           | 2       | pro monthly    | 2020-08-03   | 10     | 3             |
| 8           | 2       | pro monthly    | 2020-09-03   | 19.9   | 4             |
|...          |...      |...             |...           |...     |...            |

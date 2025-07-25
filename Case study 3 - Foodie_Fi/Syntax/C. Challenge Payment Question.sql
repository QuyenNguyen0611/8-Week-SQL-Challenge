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

SELECT * FROM payments_2020;

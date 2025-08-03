USE data_bank; 

# 1. What is the unique count and total amount for each transaction type?
SELECT 
txn_type AS transaction_type,
COUNT(DISTINCT customer_id) as count, 
sum(txn_amount) as total_amount
FROM customer_transactions
GROUP BY txn_type
ORDER BY total_amount DESC;

# 2. What is the average total historical deposit counts and amounts for all customers?
WITH deposit AS (
SELECT 
customer_id,
COUNT(txn_type) AS deposit_count,
AVG(txn_amount) AS amount
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id)

SELECT 
ROUND(AVG(deposit_count),0) AS avg_count,
ROUND(AVG(amount),1) AS avg_amount
FROM deposit;

# 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH txn_summary AS (
SELECT 
customer_id,
MONTH(txn_date) AS month,
SUM(txn_type = 'deposit') AS deposit_count,
SUM(txn_type = 'purchase') AS purchase_count,
SUM(txn_type = 'withdrawal') AS withdrawal_count
FROM customer_transactions
GROUP BY customer_id, month
)

SELECT 
month,
COUNT(*) AS qualifying_customers
FROM txn_summary
WHERE deposit_count > 1 
AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY month
ORDER BY month;

# 4. What is the closing balance for each customer at the end of the month?
WITH RECURSIVE 

-- Step 1: Generate month-end dates from 2020-01-31 to 2020-04-30
monthend_series_cte AS (
SELECT DATE('2020-01-31') AS ending_month
UNION ALL
SELECT LAST_DAY(DATE_ADD(ending_month, INTERVAL 1 MONTH))
FROM monthend_series_cte
WHERE ending_month < '2020-04-30'
),

-- Step 2: Monthly balances per customer
monthly_balances_cte AS (
  SELECT 
    customer_id,
    LAST_DAY(txn_date) AS closing_month,
    SUM(
      CASE 
        WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
        ELSE txn_amount
      END
    ) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, LAST_DAY(txn_date)
),

-- Step 3: All combinations of customer_id and ending_month
customer_months AS (
  SELECT DISTINCT c.customer_id, m.ending_month
  FROM data_bank.customer_transactions c
  CROSS JOIN monthend_series_cte m
),

-- Step 4: Join and calculate monthly change
monthly_changes_cte AS (
  SELECT 
    cm.customer_id,
    cm.ending_month,
    COALESCE(mb.transaction_balance, 0) AS total_monthly_change
  FROM customer_months cm
  LEFT JOIN monthly_balances_cte mb
    ON cm.customer_id = mb.customer_id AND cm.ending_month = mb.closing_month
),

-- Step 5: Compute cumulative ending balance
final_output AS (
  SELECT 
    customer_id,
    ending_month,
    total_monthly_change,
    SUM(total_monthly_change) OVER (
      PARTITION BY customer_id
      ORDER BY ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ending_balance
  FROM monthly_changes_cte
)

-- Final Output
SELECT 
  customer_id,
  ending_month,
  total_monthly_change,
  ending_balance
FROM final_output
ORDER BY customer_id, ending_month;

# 5. What is the percentage of customers who increase their closing balance by more than 5%?

-- This query retrieves all transactions from the customer_transactions table
-- and calculates the impact of each transaction on the customer's balance.
-- Deposits are treated as positive values and withdrawals as negative values.

WITH txn_effects AS (
SELECT
customer_id,
txn_date,
(CASE WHEN txn_type = 'deposit' THEN txn_amount
ELSE -txn_amount END) AS txn_effect
FROM customer_transactions
),

-- CTE to calculate the running balance for each customer
running_balance AS (
SELECT
customer_id,
txn_date,
SUM(txn_effect) OVER (PARTITION BY customer_id ORDER BY txn_date
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM txn_effects
),

-- CTE to calculate the closing balance at the end of each month for each customer
month_end_balance AS (
SELECT
customer_id,
DATE_FORMAT(txn_date, '%Y-%m-01') AS txn_month,
MAX(running_balance) AS closing_balance
FROM running_balance
GROUP BY customer_id, DATE_FORMAT(txn_date, '%Y-%m-01')),

-- CTE to determine the first and last month (with activity) for each customer
first_last_balance AS (
SELECT
customer_id,
MIN(txn_month) AS first_month,
MAX(txn_month) AS last_month
FROM month_end_balance
GROUP BY customer_id),

-- CTE to calculate the percentage change in balance for each customer from their first active month to their last active month
balance_change AS (
SELECT
f.customer_id,
fb.closing_balance AS first_balance,
lb.closing_balance AS last_balance,
ROUND(((lb.closing_balance - fb.closing_balance) / NULLIF(fb.closing_balance, 0)) * 100, 2) AS pct_change
FROM first_last_balance f
JOIN month_end_balance fb
ON f.customer_id = fb.customer_id AND f.first_month = fb.txn_month
JOIN month_end_balance lb
ON f.customer_id = lb.customer_id AND f.last_month = lb.txn_month)
    
SELECT 
ROUND(100*SUM(CASE WHEN pct_change > 5 THEN 1 ELSE 0 END)/ COUNT(*),0) AS pct_customer_increased
FROM balance_change;
  
  
  


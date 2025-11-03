# 1. How many unique transactions were there?
SELECT 
COUNT(distinct txn_id) as total_transactions
FROM sales;

# 2. What is the average unique products purchased in each transaction?
WITH prod_txn AS (
SELECT 
count(distinct prod_id) AS prod_count,
txn_id
FROM sales
GROUP BY txn_id)

SELECT 
ROUND(AVG(prod_count),0) AS avg_unique_products_per_transaction
FROM prod_txn;

# 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH txn_rev AS (
SELECT 
txn_id,
sum(qty*price*(100 - discount)/100) as revenue
FROM sales
GROUP BY txn_id)
,
ranked AS (
SELECT 
revenue,
ROW_NUMBER() OVER (ORDER BY revenue) AS rn,
COUNT(*) OVER () AS total_rows
FROM txn_rev
)

SELECT
ROUND(MAX(CASE WHEN rn >= 0.25 * total_rows THEN revenue END),0) AS p25,
ROUND(MAX(CASE WHEN rn >= 0.50 * total_rows THEN revenue END),0) AS p50,
ROUND(MAX(CASE WHEN rn >= 0.75 * total_rows THEN revenue END),0) AS p75
FROM ranked;

# 4. What is the average discount value per transaction?
SELECT 
txn_id,
ROUND(AVG(discount), 2) AS avg_discount_per_transaction
FROM sales
GROUP BY txn_id
ORDER BY avg_discount_per_transaction DESC;

# 5. What is the percentage split of all transactions for members vs non-members?
WITH count AS(
SELECT 
SUM(CASE WHEN member = 1 THEN 1 END) AS members,
SUM(CASE WHEN member = 0 THEN 1 END) AS non_members
FROM sales)

SELECT 
ROUND(members*100/(members+non_members),2) AS pct_members,
ROUND(non_members*100/(members+non_members),2) AS pct_non_members
FROM count;

# 6. What is the average revenue for member transactions and non-member transactions?
WITH txn_rev AS (
SELECT
txn_id,
member,
SUM(qty * price * (100 - discount) / 100.0) AS revenue
FROM sales
GROUP BY txn_id, member
)

SELECT
ROUND(AVG(CASE WHEN member = 1 THEN revenue END),0) AS member_rev,
ROUND(AVG(CASE WHEN member = 0 THEN revenue END),0) AS non_member_rev
FROM txn_rev;





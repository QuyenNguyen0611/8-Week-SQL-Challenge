# 1. What are the top 3 products by total revenue before discount?
SELECT
product_name,
SUM(qty * s.price) AS revenue
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 3;

# 2. What is the total quantity, revenue and discount for each segment?
WITH line AS (
SELECT 
pd.segment_name,
s.qty,
s.price,
s.discount
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
)

SELECT
segment_name,
SUM(qty) AS total_qty,
SUM(qty * price) AS gross_revenue,
SUM(qty * price * discount/100.0) AS total_discount_amount,
SUM(qty * price * (1 - discount/100.0)) AS net_revenue,
ROUND(AVG(discount), 2) AS avg_discount_pct
FROM line
GROUP BY segment_name
ORDER BY net_revenue DESC;

# 3. What is the top selling product for each segment?
SELECT segment_name, product_name, total_qty
FROM (
	SELECT 
    pd.segment_name,
    pd.product_name,
    SUM(s.qty) AS total_qty,
    ROW_NUMBER() OVER (
      PARTITION BY pd.segment_name 
      ORDER BY SUM(s.qty) DESC
    ) AS rnk
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY pd.segment_name, pd.product_name
) AS t
WHERE rnk = 1;

# 4. What is the total quantity, revenue and discount for each category?
WITH CTE AS (
SELECT 
category_name,
qty, 
s.price * qty*(1 - discount/100) AS revenue, 
s.price * qty * discount/100 AS discount
FROM sales s
JOIN product_details pd 
ON s.prod_id = pd.product_id)

SELECT 
category_name,
SUM(qty) AS total_quantity,
ROUND(SUM(revenue),0) AS total_revenue,
ROUND(SUM(discount),0) AS total_discount
FROM CTE
GROUP BY category_name;

# 5. What is the top selling product for each category?
SELECT category_name, product_name, total_qty
FROM (
SELECT 
pd.category_name,
pd.product_name,
SUM(s.qty) AS total_qty,
ROW_NUMBER() OVER (
PARTITION BY pd.category_name ORDER BY SUM(s.qty) DESC
) AS rnk
FROM sales s
JOIN product_details pd 
ON s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.product_name
) AS t;

# 6. What is the percentage split of revenue by product for each segment?
WITH prod_rev AS (
SELECT
p.segment_name,
p.product_name,
SUM(s.qty * s.price * (1 - s.discount/100.0)) AS revenue
FROM sales s
JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.segment_name, p.product_name
)

SELECT
segment_name,
product_name,
ROUND(
100.0 * revenue
/ SUM(revenue) OVER (PARTITION BY segment_name)
, 2) AS pct_of_product
FROM prod_rev
ORDER BY segment_name, pct_of_product DESC;

# 7. What is the percentage split of revenue by segment for each category?
WITH prod_rev AS (
SELECT
p.segment_name,
p.category_name,
SUM(s.qty * s.price * (1 - s.discount/100.0)) AS revenue
FROM sales s
JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.segment_name, p.category_name
)

SELECT
segment_name,
category_name,
ROUND(
100.0 * revenue
/ SUM(revenue) OVER (PARTITION BY category_name)
, 2) AS pct_of_segment
FROM prod_rev
ORDER BY segment_name, pct_of_segment DESC;

# 8. What is the percentage split of total revenue by category?
WITH prod_rev AS (
SELECT
p.category_name,
SUM(s.qty * s.price * (1 - s.discount/100.0)) AS revenue
FROM sales s
JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.category_name
)

SELECT
category_name,
ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total_revenue
FROM prod_rev
ORDER BY pct_of_total_revenue DESC;

# 9. What is the total transaction “penetration” for each product? 
# (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

WITH txn_counts AS (
  -- total transactions that bought each product
SELECT
s.prod_id,
COUNT(DISTINCT s.txn_id) AS txn_with_product
FROM sales s
GROUP BY s.prod_id
),
total_txn AS (
  -- total number of transactions overall
SELECT COUNT(DISTINCT txn_id) AS total_txn
FROM sales
)
SELECT
p.product_name,
ROUND(100.0 * t.txn_with_product / tt.total_txn, 2) AS penetration_pct
FROM txn_counts t
CROSS JOIN total_txn tt
JOIN product_details p
ON t.prod_id = p.product_id
ORDER BY penetration_pct DESC;

# 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
WITH presence AS (
  -- one row per (txn, product) with positive quantity
  SELECT txn_id, prod_id
  FROM sales
  GROUP BY txn_id, prod_id
  HAVING SUM(qty) > 0
)
SELECT
  pd1.product_name AS product_1,
  pd2.product_name AS product_2,
  pd3.product_name AS product_3,
  COUNT(DISTINCT a.txn_id) AS txn_count
FROM presence a
JOIN presence b
  ON a.txn_id = b.txn_id AND a.prod_id < b.prod_id
JOIN presence c
  ON a.txn_id = c.txn_id AND b.prod_id < c.prod_id
JOIN product_details pd1 ON pd1.product_id = a.prod_id
JOIN product_details pd2 ON pd2.product_id = b.prod_id
JOIN product_details pd3 ON pd3.product_id = c.prod_id
GROUP BY pd1.product_name, pd2.product_name, pd3.product_name
ORDER BY txn_count DESC
LIMIT 1;     -- change to 10 to see top 10 combos




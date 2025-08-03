USE data_bank;

# 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) as unique_nodes
FROM customer_nodes;

# 2. What is the number of nodes per region?
SELECT 
r.region_name,
COUNT(DISTINCT node_id) AS total_nodes
FROM customer_nodes c
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;

# 3. How many customers are allocated to each region?
SELECT 
r.region_name,
COUNT(DISTINCT customer_id) as total_customers
FROM customer_nodes C
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY total_customers DESC;

# 4. How many days on average are customers reallocated to a different node?
SELECT 
ROUND(AVG(DATEDIFF(end_date, start_date)), 2) AS avg_days_in_node
FROM customer_nodes
WHERE end_date != '9999-12-31';

# 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH node_days AS (
SELECT 
region_id,
DATEDIFF(end_date, start_date) AS reallocation_days
FROM customer_nodes
WHERE end_date != '9999-12-31'
),
ranked AS (
SELECT 
region_id,
reallocation_days,
NTILE(100) OVER (PARTITION BY region_id ORDER BY reallocation_days) AS percentile_rank
FROM node_days
)
SELECT 
region_id,
MAX(CASE WHEN percentile_rank = 50 THEN reallocation_days END) AS median_days,
MAX(CASE WHEN percentile_rank = 80 THEN reallocation_days END) AS p80_days,
MAX(CASE WHEN percentile_rank = 95 THEN reallocation_days END) AS p95_days
FROM ranked
GROUP BY region_id
ORDER BY region_id;

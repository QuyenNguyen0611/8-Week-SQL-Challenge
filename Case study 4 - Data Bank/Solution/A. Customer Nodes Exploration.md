# Case Study #4: Data Bank

## A. Customer Nodes Exporation

### Question 1: How many unique nodes are there on the Data Bank system?

```sql
SELECT COUNT(DISTINCT node_id) as unique_nodes
FROM customer_nodes;
```

| unique_nodes |
|--------------|
| 5            |

### Question 2:  What is the number of nodes per region?
```sql
SELECT 
r.region_name,
COUNT(DISTINCT node_id) AS total_nodes
FROM customer_nodes c
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;
```
| region_name | total_nodes |
|-------------|-------------|
| Africa      | 5           |
| America     | 5           |
| Asia        | 5           |
| Australia   | 5           |
| Europe      | 6           |

### Question 3: How many customers are allocated to each region?
```sql
SELECT 
r.region_name,
COUNT(DISTINCT customer_id) as total_customers
FROM customer_nodes C
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name
ORDER BY total_customers DESC;
```
| region_name | total_customers |
|-------------|-----------------|
| Australia   | 110             |
| America     | 105             |
| Africa      | 102             |
| Asia        | 95              |
| Europe      | 88              |

### Question 4: How many days on average are customers reallocated to a different node?
```sql
SELECT 
ROUND(AVG(DATEDIFF(end_date, start_date)), 2) AS avg_days_in_node
FROM customer_nodes
WHERE end_date != '9999-12-31';
```

| avg_days_in_node |
|------------------|
| 14.63            |

### Question 5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
1. Calculate reallocation days
``` sql
SELECT 
region_id,
DATEDIFF(end_date, start_date) AS reallocation_days
FROM customer_nodes
WHERE end_date != '9999-12-31'
```
| region_id | reallocation_days |
|-----------|-------------------|
| 3         | 1                 |
| 3         | 14                |
| 5         | 22                |
| ...       | ...               |

2. Assign rank and count per region

I assign a rank (`RANK()`) to each row ordered by `reallocation_days`, partitioned by `region_id`. 
This helps group identical values under the same rank. We also count total rows per region using `COUNT()`.

```sql
WITH node_days AS (
-- Calculate reallocation days
SELECT 
region_id,
DATEDIFF(end_date, start_date) AS reallocation_days
FROM customer_nodes
WHERE end_date != '9999-12-31'
),
ranked AS (
-- Assign percentile ranks per region
SELECT 
region_id,
reallocation_days,
RANK() OVER (PARTITION BY region_id ORDER BY reallocation_days) AS rnk,
COUNT(*) OVER (PARTITION BY region_id) AS total_rows
FROM node_days
)
SELECT *
FROM ranked;
```

| region_id | reallocation_days | rnk  | total_rows |
|-----------|-------------------|------|------------|
| 1         | 0                 | 1    | 660        |
| 1         | 0                 | 1    | 660        |
| ...       | ...               | ...  |...         |

3. Calculate approximate percentile rank

In this step, I simulated percentile values using the formula:
```sql
(rnk - 1) / (total_rows - 1)
```

This formula gives each unique value in `reallocation_days` a percentile (between 0 and 1) within its region. 
Using `RANK()` ensures values that are equal receive the same percentile.

```sql
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
RANK() OVER (PARTITION BY region_id ORDER BY reallocation_days) AS rnk,
COUNT(*) OVER (PARTITION BY region_id) AS total_rows
FROM node_days
),

with_percentile AS (
SELECT 
region_id,
reallocation_days,
rnk,
total_rows,
(rnk - 1) / (total_rows - 1) AS approx_percentile
FROM ranked
WHERE total_rows > 1
)

SELECT * FROM with_percentile
;
```
| region_id | reallocation_days | rnk  | total_rows | approx_percentile |
|-----------|-------------------|------|------------|-------------------|
| ...       | ...               | ...  |...         | ...               |
| 1         | 1                 | 16   | 660        | 0.0228            |
| ...       | ...               | ...  |...         | ...               |

4. Extract 50th (Median), 80th, and 95th percentiles per region
In the final step, I use conditional aggregation to select the minimum `reallocation_days` for each region where the `approx_percentile` first meets or exceeds the desired thresholds (50%, 80%, 95%).

```sql
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
RANK() OVER (PARTITION BY region_id ORDER BY reallocation_days) AS rnk,
COUNT(*) OVER (PARTITION BY region_id) AS total_rows
FROM node_days
),

with_percentile AS (
SELECT 
region_id,
reallocation_days,
rnk,
total_rows,
(rnk - 1) / (total_rows - 1) AS approx_percentile
FROM ranked
WHERE total_rows > 1
),

selected AS (
SELECT 
region_id,
MIN(CASE WHEN approx_percentile >= 0.5 THEN reallocation_days END) AS median_days,
MIN(CASE WHEN approx_percentile >= 0.8 THEN reallocation_days END) AS p80_days,
MIN(CASE WHEN approx_percentile >= 0.95 THEN reallocation_days END) AS p95_days
FROM with_percentile
GROUP BY region_id
)

SELECT * FROM selected
ORDER BY region_id;
```

| region_id | median_days | p80_days | p95_days |
|-----------|-------------|----------|----------|
| 1         | 16          | 24       | 29       |
| 2         | 16          | 24       | 29       |
| 3         | 16          | 25       | 29       |
| 4         | 16          | 24       | 29       |
| 6         | 16          | 25       | 29       |

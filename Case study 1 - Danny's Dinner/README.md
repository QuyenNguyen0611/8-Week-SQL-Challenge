
# 🍜 Case Study #1 - Danny's Diner

---

### 1. What is the total amount each customer spent at the restaurant?
```sql
SELECT s.customer_id, SUM(m.price) AS total_spent
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;
```

| customer_id | total_spent |
|-------------|-------------|
| A           | 76          |
| B           | 74          |
| C           | 36          |

### 2. How many days has each customer visited the restaurant?
```sql
SELECT customer_id, COUNT(DISTINCT order_date) as days
FROM sales 
GROUP BY customer_id;
```
| customer_id | days |
|-------------|------|
| A           | 4    |
| B           | 6    |
| C           | 2    |

### 3. What is the first item from menu purchased by each customer?
```sql
WITH CTE AS (
  SELECT s.customer_id, m.product_name, s.order_date,
         ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, product_name, order_date
FROM CTE
WHERE rn = 1;
```
| customer_id | product_name | order_date |
|-------------|--------------|------------|
| A           | sushi        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |

### 4. What is the most purchased item and how many times?
```sql
SELECT m.product_name, COUNT(*) AS times
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY times DESC
LIMIT 1;
```
| product_name | times |
|--------------|-------|
| ramen        | 8     |

### 5. Which item was most popular per customer?
```sql
WITH purchase_counts AS (
  SELECT customer_id, product_id, COUNT(*) AS purchase_count
  FROM sales
  GROUP BY customer_id, product_id
),
max_purchases AS (
  SELECT customer_id, MAX(purchase_count) AS max_purchase
  FROM purchase_counts
  GROUP BY customer_id
)
SELECT pc.customer_id, pc.product_id, m.product_name, mp.max_purchase
FROM purchase_counts pc
JOIN max_purchases mp 
  ON pc.customer_id = mp.customer_id AND pc.purchase_count = mp.max_purchase
JOIN menu m ON pc.product_id = m.product_id
ORDER BY pc.customer_id;
```
| customer_id | product_id | product_name | max_purchase |
|-------------|------------|--------------|--------------|
| A           | 3          | ramen        | 3            |
| B           | 1          | sushi        | 2            |
| B           | 2          | curry        | 2            |
| B           | 3          | ramen        | 2            |
| C           | 3          | ramen        | 3            |

### 6. Which item was purchased first by the customer after they became a member?
```sql
WITH CTE AS (
  SELECT m.customer_id, m.join_date, s.order_date, s.product_id,
         ROW_NUMBER() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) AS rn
  FROM members m
  JOIN sales s ON m.customer_id = s.customer_id
  WHERE m.join_date <= s.order_date
)
SELECT c.customer_id, c.join_date, c.order_date, m2.product_name
FROM CTE c
JOIN menu m2 ON c.product_id = m2.product_id
WHERE rn = 1
ORDER BY c.customer_id;
```
| customer_id | join_date  | order_date | product_name |
|-------------|------------|------------|--------------|
| A           | 2021-01-07 | 2021-01-07 | curry        |
| B           | 2021-01-09 | 2021-01-11 | sushi        |

### 7. Which item was purchased just before the customer became a member?
```sql
WITH CTE AS (
  SELECT m.customer_id, m.join_date, s.order_date, s.product_id,
         ROW_NUMBER() OVER (PARTITION BY m.customer_id ORDER BY s.order_date DESC) AS rn
  FROM members m
  JOIN sales s ON m.customer_id = s.customer_id
  WHERE m.join_date > s.order_date
)
SELECT c.customer_id, c.join_date, c.order_date, m2.product_name
FROM CTE c
JOIN menu m2 ON c.product_id = m2.product_id
WHERE rn = 1
ORDER BY c.customer_id;
```
| customer_id | join_date  | order_date | product_name |
|-------------|------------|------------|--------------|
| A           | 2021-01-07 | 2021-01-01 | sushi        |
| B           | 2021-01-09 | 2021-01-04 | sushi        |

### 8. What is the total items and amount spent for each member before they became a member?
```sql
WITH CTE AS (
  SELECT m.customer_id, m.join_date, s.order_date, s.product_id
  FROM members m
  JOIN sales s ON m.customer_id = s.customer_id
  WHERE m.join_date > s.order_date
)
SELECT c.customer_id, COUNT(*) AS total_items, SUM(m2.price) AS total_spent
FROM CTE c
JOIN menu m2 ON c.product_id = m2.product_id
GROUP BY c.customer_id
ORDER BY c.customer_id;
```
| customer_id | total_items | total_spent |
|-------------|-------------|-------------|
| A           | 2           | 25          |
| B           | 3           | 40          |

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
WITH calculate_point AS (
  SELECT product_id, product_name,
         CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END AS points
  FROM menu
)
SELECT s.customer_id, SUM(c.points) AS total_points
FROM sales s 
JOIN calculate_point c ON s.product_id = c.product_id
GROUP BY s.customer_id;
```
| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 360          |

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
WITH date_table AS (
  SELECT customer_id, join_date,
         DATE_ADD(join_date, INTERVAL 6 DAY) AS first_week,
         LAST_DAY(join_date) AS last_date
  FROM members
),
CTE AS (
  SELECT d.customer_id, d.join_date, s.order_date, d.first_week, d.last_date, m.product_name, m.price
  FROM date_table d 
  JOIN sales s ON d.customer_id = s.customer_id
  JOIN menu m ON m.product_id = s.product_id
)
SELECT customer_id, 
       SUM(
         CASE 
           WHEN order_date BETWEEN join_date AND first_week THEN price * 20
           WHEN product_name = 'sushi' THEN price * 20
           ELSE price * 10
         END
       ) AS points
FROM CTE
GROUP BY customer_id 
ORDER BY customer_id;
```
| customer_id | points |
|-------------|--------|
| A           | 1370   |
| B           | 940    |

### 🧩 Bonus A: Join All The Things

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

![Screen Shot 2025-06-06 at 20 49 47](https://github.com/user-attachments/assets/cb4d0a27-6fbc-4e01-a058-6099bdda0c1d)

```sql
SELECT s.customer_id, s.order_date, m.product_name, m.price,
       CASE WHEN s.order_date >= mb.join_date THEN 'Y' ELSE 'N' END AS member
FROM sales s 
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mb ON s.customer_id = mb.customer_id;
```
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

### 🧩 Bonus B: Rank All The Things

Danny also requires further information about the `ranking` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null `ranking` values for the records when customers are not yet part of the loyalty program.

```sql
WITH basic_data AS (
  SELECT s.customer_id, s.order_date, m.product_name, m.price,
         CASE WHEN s.order_date >= mb.join_date THEN 'Y' ELSE 'N' END AS member
  FROM sales s 
  JOIN menu m ON s.product_id = m.product_id
  LEFT JOIN members mb ON s.customer_id = mb.customer_id
)
SELECT customer_id, order_date, product_name, price, member,
       CASE WHEN member = 'N' THEN NULL
            ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
       END AS ranking
FROM basic_data;
```
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | curry        | 15    | N      | null    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | null    |
| B           | 2021-01-02 | curry        | 15    | N      | null    |
| B           | 2021-01-04 | sushi        | 10    | N      | null    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-07 | ramen        | 12    | N      | null    |


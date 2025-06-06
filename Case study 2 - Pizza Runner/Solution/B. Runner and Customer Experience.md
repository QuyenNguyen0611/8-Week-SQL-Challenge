
# 🍕 Case Study #2: Pizza Runner

## B. Runner and Delivery Insights

---

### 1. How many runners signed up for each 1-week period?
```sql
SELECT 
  TIMESTAMPDIFF(WEEK, '2021-01-01', registration_date) + 1 AS signup_week,
  COUNT(DISTINCT runner_id) AS runner_count
FROM runners
GROUP BY signup_week;
```
| signup_week | runner_count |
|-------------|---------------|
| 1           | 2             |
| 2           | 1             |
| 3           | 1             |

---

### 2. What was the average time (in minutes) it took each runner to arrive at Pizza Runner HQ?
```sql
SELECT runner_id,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)), 0) AS avg_pickup
FROM runner_orders_temp
JOIN customer_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY runner_id;
```
| runner_id | avg_pickup |
|-----------|------------|
| 1         | 15         |
| 2         | 23         |
| 3         | 10         |

---

### 3. Is there any relationship between the number of pizzas and order prep time?
```sql
SELECT order_id, 
       COUNT(pizza_id) AS number_of_pizza,
       ROUND(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS time_prepare
FROM runner_orders_temp
JOIN customer_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY order_id, order_time, pickup_time
ORDER BY number_of_pizza;
```
> **Observation:**
- 1 pizza: mostly 10 minutes
- 2 pizzas: 15–21 minutes
- 3 pizzas: ~29 minutes
- Prep time increases with pizza quantity.

| order_id | number_of_pizzas | time_prepare |
|----------|------------------|--------------|
| 1        | 1                | 10           |
| 2        | 1                | 10           |
| 5        | 1                | 10           |
| 7        | 1                | 10           |
| 8        | 1                | 20           |
| 3        | 2                | 21           |
| 10       | 2                | 15           |
| 4        | 3                | 29           |

---

### 4. What was the average distance travelled for each customer?
```sql
SELECT customer_id, 
       ROUND(AVG(distance), 2) AS avg_distance
FROM runner_orders_temp
JOIN customer_orders_temp USING (order_id)
WHERE distance IS NOT NULL
GROUP BY customer_id;
```
| customer_id | avg_distance |
|-------------|--------------|
| 101         | 20           |
| 102         | 16.73        |
| 103         | 23.4         |
| 104         | 10           |
| 105         | 25           |

---

### 5. What was the difference between the longest and shortest delivery times?
```sql
SELECT (MAX(duration) - MIN(duration)) AS time_diff
FROM runner_orders_temp;
```
| time_diff |
|-----------|
| 30        |

---

### 6. What was the average speed for each runner per delivery?
```sql
SELECT 
  runner_id, 
  order_id, 
  distance,
  ROUND(60 * distance / duration, 2) AS avg_speed
FROM runner_orders_temp
WHERE duration IS NOT NULL
ORDER BY runner_id;
```
| runner_id | order_id | distance | avg_speed |
|-----------|----------|----------|-----------|
| 1         | 1        | 20       | 37.5      |
| 1         | 2        | 20       | 44.44     |
| 1         | 3        | 13.4     | 40.2      |
| 1         | 10       | 10       | 60        |
| 2         | 4        | 23.4     | 35.1      |
| 2         | 7        | 25       | 60        |
| 2         | 8        | 23.4     | 93.6      |
| 3         | 5        | 10       | 40        |

- Runner 1 delivered 4 orders; avg_speed ranges from 37.5 to 60.
- Runner 2 had 3 orders; highest speed is 93.6 (order 8 — likely an outlier).
- Runner 3 has 1 order (order 5) with a consistent speed of 40.

---

### 7. What is the successful delivery percentage for each runner?
```sql
SELECT runner_id, 
       ROUND(COUNT(distance) * 100 / COUNT(order_id), 0) AS percentage_success
FROM runner_orders_temp
GROUP BY runner_id;
```
| runner_id | percentage_success |
|-----------|--------------------|
| 1         | 100                |
| 2         | 75                 |
| 3         | 50                 |

---

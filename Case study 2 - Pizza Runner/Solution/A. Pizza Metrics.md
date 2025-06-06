# 🍕 Case Study #2: Pizza Runner

## A. Pizza Metrics

---

## 🧹 STEP 1: Data Cleaning

### 🔸 Clean `customer_orders` → `customer_orders_temp`

```sql
DROP TABLE IF EXISTS customer_orders_temp;

CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  order_time,
  CASE 
    WHEN exclusions IN ('null', 'NaN', '') THEN NULL
    ELSE exclusions
  END AS exclusions, 
  CASE 
    WHEN extras IN ('null', 'NaN', '') THEN NULL
    ELSE extras
  END AS extras
FROM customer_orders;

SELECT * FROM customer_orders_temp;
```
| order_id | customer_id | pizza_id | order_time           | exclusions | extras |
|----------|-------------|----------|----------------------|------------|--------|
| 1        | 101         | 1        | 2020-01-01 18:05:02  | NULL       | NULL   |
| 2        | 101         | 1        | 2020-01-01 19:00:52  | NULL       | NULL   |
| 3        | 102         | 1        | 2020-01-02 23:51:23  | NULL       | NULL   |
| 3        | 102         | 2        | 2020-01-02 23:51:23  | NULL       | NULL   |
| 4        | 103         | 1        | 2020-01-04 13:23:46  | 4          | NULL   |
| 4        | 103         | 1        | 2020-01-04 13:23:46  | 4          | NULL   |
| 4        | 103         | 2        | 2020-01-04 13:23:46  | 4          | NULL   |
| 5        | 104         | 1        | 2020-01-08 21:00:29  | NULL       | 1      |
| 6        | 101         | 2        | 2020-01-08 21:03:13  | NULL       | NULL   |
| 7        | 105         | 2        | 2020-01-08 21:20:29  | NULL       | 1      |
| 8        | 102         | 1        | 2020-01-09 23:54:33  | NULL       | NULL   |
| 9        | 103         | 1        | 2020-01-10 11:22:59  | 4          | 1, 5   |
| 10       | 104         | 1        | 2020-01-11 18:34:49  | NULL       | NULL   |
| 10       | 104         | 1        | 2020-01-11 18:34:49  | 2, 6       | 1, 4   |

---

### 🔸 Clean `runner_orders` → `runner_orders_temp`

```sql
DROP TABLE IF EXISTS runner_orders_temp;

CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT 
  order_id, 
  runner_id, 
  CASE 
    WHEN pickup_time = 'null' THEN NULL
    ELSE pickup_time
  END AS pickup_time,

  CAST(
    CASE 
      WHEN distance = 'null' THEN NULL 
      WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
      ELSE distance
    END AS FLOAT
  ) AS distance,

  CAST(
    CASE 
      WHEN duration = 'null' THEN NULL 
      WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
      WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
      WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
      ELSE duration
    END AS FLOAT
  ) AS duration,

  CASE 
    WHEN cancellation IN ('null', 'NaN', '') THEN NULL 
    ELSE cancellation
  END AS cancellation
FROM runner_orders;

SELECT * FROM runner_orders_temp;
```
| order_id | runner_id | pickup_time            | distance | duration | cancellation            |
|----------|-----------|------------------------|----------|----------|-------------------------|
| 1        | 1         | 2020-01-01 18:15:34    | 20       | 32       | NULL                    |
| 2        | 1         | 2020-01-01 19:10:54    | 20       | 27       | NULL                    |
| 3        | 1         | 2020-01-03 00:12:37    | 13.4     | 20       | NULL                    |
| 4        | 2         | 2020-01-04 13:53:03    | 23.4     | 40       | NULL                    |
| 5        | 3         | 2020-01-08 21:10:57    | 10       | 15       | NULL                    |
| 6        | 3         | NULL                   | NULL     | NULL     | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45    | 25       | 25       | NULL                    |
| 8        | 2         | 2020-01-10 00:15:02    | 23.4     | 15       | NULL                    |
| 9        | 2         | NULL                   | NULL     | NULL     | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20    | 10       | 10       | NULL                    |

---

## ✅ STEP 2: Answer Questions

### 1. How many pizzas were ordered?
```sql
SELECT COUNT(order_id) AS pizza_count
FROM customer_orders_temp;
```
| pizza_count |
|-------------|
| 14          |

### 2. How many unique customer orders were made?
```sql
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM customer_orders_temp;
```
| total_orders |
|--------------|
| 10           |

### 3. How many successful orders were delivered by each runner?
```sql
SELECT runner_id, 
       COUNT(DISTINCT order_id) AS successful_orders
FROM runner_orders_temp 
WHERE cancellation IS NULL
GROUP BY runner_id;
```
| runner_id | successful_orders |
|-----------|-------------------|
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |


### 4. How many of each type of pizza was delivered?
```sql
SELECT p.pizza_name,
       COUNT(*) AS deliver_count
FROM customer_orders_temp c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
WHERE c.order_id IN (
  SELECT order_id 
  FROM runner_orders_temp
  WHERE cancellation IS NULL
)
GROUP BY p.pizza_name;
```
| pizza_name | deliver_count |
|------------|----------------|
| Meatlovers | 9              |
| Vegetarian | 3              |

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
SELECT customer_id,
       SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
       SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM customer_orders_temp
GROUP BY customer_id;
```
| customer_id | Meatlovers | Vegetarian |
|-------------|------------|------------|
| 101         | 2          | 1          |
| 102         | 2          | 1          |
| 103         | 3          | 1          |
| 104         | 3          | 0          |
| 105         | 0          | 1          |

### 6. What was the maximum number of pizzas delivered in a single order?
```sql
SELECT c.order_id, 
       COUNT(c.pizza_id) AS total_pizzas
FROM customer_orders_temp c
JOIN runner_orders_temp r USING(order_id)
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY total_pizzas DESC
LIMIT 1;
```
| order_id | total_pizzas |
|----------|--------------|
| 4        | 3            |

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT customer_id,
       SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS has_change,
       SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM runner_orders_temp
JOIN customer_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id;
```
| customer_id | has_change | no_change |
|-------------|------------|-----------|
| 101         | 0          | 2         |
| 102         | 0          | 3         |
| 103         | 3          | 0         |
| 104         | 2          | 1         |
| 105         | 1          | 0         |

### 8. How many pizzas were delivered that had both exclusions and extras?
```sql
SELECT 
  SUM(CASE 
        WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
        ELSE 0 
      END) AS change_both
FROM runner_orders_temp
JOIN customer_orders_temp USING (order_id)
WHERE cancellation IS NULL;
```
| change_both |
|-------------|
| 1           |

### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT HOUR(order_time) AS hour_of_day,
       COUNT(pizza_id) AS pizza_volume
FROM customer_orders_temp
GROUP BY hour_of_day
ORDER BY hour_of_day;
```
| hour_of_day | pizza_volume |
|-------------|--------------|
| 11          | 1            |
| 13          | 3            |
| 18          | 3            |
| 19          | 1            |
| 21          | 3            |
| 23          | 3            |

### 10. What was the volume of orders for each day of the week?
```sql
SELECT DAYNAME(order_time) AS day_of_week,
       COUNT(DISTINCT order_id) AS orders_volume
FROM customer_orders_temp
GROUP BY day_of_week;
```
| day_of_week | orders_volume |
|-------------|----------------|
| Friday      | 1              |
| Saturday    | 2              |
| Thursday    | 2              |
| Wednesday   | 5              |


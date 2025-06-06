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
![Screen Shot 2025-06-05 at 17 29 29](https://github.com/user-attachments/assets/4d667f69-4085-43bf-9fb1-fd621b9b3609)

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
![Screen Shot 2025-06-05 at 17 29 48](https://github.com/user-attachments/assets/a474795e-5ef1-4241-842c-2b2e86af5d71)

---

## ✅ STEP 2: Answer Questions

### 1. How many pizzas were ordered?
```sql
SELECT COUNT(order_id) AS pizza_count
FROM customer_orders_temp;
```
![Screen Shot 2025-06-05 at 17 30 51](https://github.com/user-attachments/assets/ee99c4d2-fec6-4be5-af39-324054797ee6)

### 2. How many unique customer orders were made?
```sql
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM customer_orders_temp;
```
![Screen Shot 2025-06-05 at 17 31 07](https://github.com/user-attachments/assets/0b757b5e-ce39-4749-9283-f8a3e68e407d)

### 3. How many successful orders were delivered by each runner?
```sql
SELECT runner_id, 
       COUNT(DISTINCT order_id) AS successful_orders
FROM runner_orders_temp 
WHERE cancellation IS NULL
GROUP BY runner_id;
```
![Screen Shot 2025-06-05 at 17 31 22](https://github.com/user-attachments/assets/2b199c5c-4649-447e-9376-abf0b9f0b59f)

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
![Screen Shot 2025-06-05 at 17 31 34](https://github.com/user-attachments/assets/3142a185-b762-436a-b51b-33e0bd79abe3)

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
SELECT customer_id,
       SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
       SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM customer_orders_temp
GROUP BY customer_id;
```
![Screen Shot 2025-06-05 at 17 31 47](https://github.com/user-attachments/assets/f173ef99-9216-46bb-8417-3ac7b4b30a96)

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
![Screen Shot 2025-06-05 at 17 32 03](https://github.com/user-attachments/assets/8ea54031-fea9-4790-aebb-16fa03ff6a88)

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
![Screen Shot 2025-06-05 at 17 32 19](https://github.com/user-attachments/assets/e5f8dec2-a08e-4c64-9e9c-6f00baa9eaa7)

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
![Screen Shot 2025-06-05 at 17 32 32](https://github.com/user-attachments/assets/34debc14-6d2b-423a-ade3-8f3120804b74)


### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT HOUR(order_time) AS hour_of_day,
       COUNT(pizza_id) AS pizza_volume
FROM customer_orders_temp
GROUP BY hour_of_day
ORDER BY hour_of_day;
```
![Screen Shot 2025-06-05 at 17 32 49](https://github.com/user-attachments/assets/eade65f9-6b25-4dde-80e5-90a41e576546)

### 10. What was the volume of orders for each day of the week?
```sql
SELECT DAYNAME(order_time) AS day_of_week,
       COUNT(DISTINCT order_id) AS orders_volume
FROM customer_orders_temp
GROUP BY day_of_week;
```
![Screen Shot 2025-06-05 at 17 33 02](https://github.com/user-attachments/assets/ab3ea98a-fad7-4c8f-acce-5a26cd8a286a)

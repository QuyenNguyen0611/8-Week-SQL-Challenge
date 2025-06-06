# A. Pizza Metrics
# STEP 1: DATA CLEANING
DROP TABLES IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT 
order_id, 
customer_id, 
pizza_id, 
order_time,
(CASE 
WHEN exclusions IN ('null', 'NaN', '') THEN NULL
ELSE exclusions END) AS exclusions, 
(CASE 
WHEN extras IN ('null', 'NaN', '') THEN NULL
ELSE extras END) AS extras
FROM customer_orders;

SELECT * 
FROM customer_orders_temp;

DROP TABLES IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT order_id, runner_id, 
(CASE WHEN pickup_time = 'null' THEN NULL
ELSE pickup_time END) AS pickup_time,
CAST(
CASE WHEN distance = 'null' THEN NULL 
WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
ELSE distance END AS FLOAT) AS distance,
CAST(
CASE WHEN duration = 'null' THEN NULL 
WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
ELSE duration END AS FLOAT) AS duration,
(CASE WHEN cancellation IN ('null', 'NaN', '') THEN NULL 
ELSE cancellation END) AS cancellation
FROM runner_orders;

SELECT * 
FROM runner_orders_temp;

# STEP 2. ANSWER QUESTIONS
# 1. How many pizzas were ordered?
SELECT COUNT(order_id) AS pizza_count
FROM customer_orders_temp;

# 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM customer_orders_temp;

# 3. How many successful orders were delivered by each runner?
SELECT runner_id, 
COUNT(DISTINCT order_id) AS successful_orders
FROM runner_orders_temp 
WHERE cancellation IS NULL
GROUP BY runner_id;

# 4. How many of each type of pizza was delivered?
SELECT 
p.pizza_name,
COUNT(*) AS deliver_count
FROM customer_orders_temp c
JOIN pizza_names p 
ON c.pizza_id = p.pizza_id
WHERE c.order_id IN (
SELECT order_id 
FROM runner_orders_temp
WHERE cancellation IS NULL)
GROUP BY p.pizza_name;

# 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,
SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM customer_orders_temp
GROUP BY customer_id;

# 6. What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id, COUNT(c.pizza_id) AS total_pizzas
FROM customer_orders_temp c
JOIN runner_orders_temp r USING(order_id)
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY total_pizzas DESC
LIMIT 1;

# 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS has_change,
SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM runner_orders_temp
JOIN customer_orders_temp
USING (order_id)
WHERE cancellation IS NULL
GROUP BY customer_id;

# 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
SUM(CASE 
	WHEN exclusions IS NOT NULL 
	AND extras IS NOT NULL THEN 1
	ELSE 0 END) AS change_both
FROM runner_orders_temp
JOIN customer_orders_temp
USING (order_id)
WHERE cancellation IS NULL;

# 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hour_of_day,
COUNT(pizza_id) AS pizza_volume
FROM customer_orders_temp
GROUP BY hour_of_day
ORDER BY hour_of_day;

# 10. What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS day_of_week,
COUNT(DISTINCT order_id) as orders_volume
FROM customer_orders_temp
GROUP BY day_of_week;






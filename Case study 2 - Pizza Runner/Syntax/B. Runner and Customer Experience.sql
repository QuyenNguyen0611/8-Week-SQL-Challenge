# 1. How many runners signed up for each 1 week period? 
SELECT 
TIMESTAMPDIFF(WEEK, '2021-01-01', registration_date) + 1 AS signup_week,
COUNT(DISTINCT runner_id) as runner_count
FROM runners
GROUP BY signup_week;

# 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,
ROUND(AVG(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)),0) AS avg_pickup
FROM runner_orders_temp
JOIN customer_orders_temp
USING (order_id)
WHERE cancellation IS NULL
GROUP BY runner_id;

# 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT order_id, 
COUNT(pizza_id) AS number_of_pizza,
ROUND(TIMESTAMPDIFF(MINUTE, order_time, pickup_time)) AS time_prepare
FROM runner_orders_temp
JOIN customer_orders_temp USING (order_id)
WHERE cancellation IS NULL
GROUP BY order_id, order_time, pickup_time
ORDER BY number_of_pizza;
/* Prep time usually increases with more pizzas
1 pizza: mostly 10 mins
2 pizza: 15 - 21 mins
3 pizza: 29 mins */

# 4. What was the average distance travelled for each customer?
SELECT customer_id, 
ROUND(avg(distance),2) AS avg_distance
FROM runner_orders_temp
JOIN customer_orders_temp
USING(order_id)
WHERE distance IS NOT NULL
GROUP BY customer_id;

# 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT (MAX(duration) - MIN(duration)) AS time_diff
FROM runner_orders_temp;

# 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
runner_id, 
order_id, 
distance,
ROUND(60*distance/duration,2) AS avg_speed
FROM runner_orders_temp
WHERE duration IS NOT NULL
ORDER BY runner_id;

# 7. What is the successful delivery percentage for each runner?
SELECT runner_id, 
ROUND(COUNT(distance)*100/ COUNT(order_id),0) AS percentage_success
FROM runner_orders_temp
GROUP BY runner_id;
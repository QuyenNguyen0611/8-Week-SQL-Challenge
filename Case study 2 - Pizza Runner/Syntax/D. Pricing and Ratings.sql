/* Q1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 
and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees? */
SELECT
SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 12
ELSE 10 END) AS total_sales
FROM customer_orders_temp c
JOIN pizza_names p
USING (pizza_id)
RIGHT JOIN runner_orders_temp r
USING(order_id)
WHERE cancellation IS NULL;

# Q2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

# SET @basecost := 138;
SELECT 
@basecost + SUM(
CASE 
WHEN p.topping_name = 'Cheese' THEN 2
ELSE 1 END) AS updated_money
FROM extras_split e
JOIN pizza_toppings p 
ON e.extra_id = p.topping_id;

/* Q3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5. */

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
order_id INT,
rating INT);

INSERT INTO ratings
(order_id, rating)
VALUES 
(1,4),
(2,5),
(3,5),
(4,3),
(5,4),
(7,4),
(8,3),
(10,5)
;

SELECT * FROM ratings;

/* Q4. Using your newly generated table - 
can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas */

SELECT 
c.customer_id,
r.order_id, 
o.runner_id, 
r.rating,
c.order_time,
o.pickup_time, 
TIMESTAMPDIFF(MINUTE, c.order_time, o.pickup_time) AS order_to_pickup_time,
o.duration, 
ROUND(AVG(60*o.distance/o.duration),2) AS avg_speed, 
COUNT(c.order_id) AS pizza_count
FROM ratings r
JOIN runner_orders_temp o
ON r.order_id = o.order_id
JOIN customer_orders_temp c
ON c.order_id = r.order_id
GROUP BY c.customer_id,
r.order_id, 
o.runner_id, 
r.rating,
c.order_time,
o.pickup_time, 
o.duration;

/* Q5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
and each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries? */

SELECT 
@basecost AS revenue,
ROUND(SUM(distance)*0.3,2) AS runner_paid,
ROUND(@basecost - SUM(distance)*0.3,2) AS money_left
FROM runner_orders_temp;
# DATA CLEANING
-- 1. Create a temporary table 'topping_split' to separate toppings
DROP TABLE IF EXISTS pizza_recipes_temp;

CREATE TEMPORARY TABLE pizza_recipes_temp AS
SELECT
  pizza_id,
  CAST(topping AS UNSIGNED) AS topping_id
FROM pizza_recipes,
JSON_TABLE(
  CONCAT('["', REPLACE(toppings, ',', '","'), '"]'),
  '$[*]' COLUMNS (topping VARCHAR(10) PATH '$')
) AS jt;

SELECT * FROM pizza_recipes_temp;

DROP TABLE IF EXISTS topping_split;
CREATE TEMPORARY TABLE topping_split AS
SELECT pizza_id, topping_id, topping_name
FROM pizza_recipes_temp
JOIN pizza_toppings
USING(topping_id);

SELECT * FROM topping_split;
-- 2. Add an identity column record_id to 'customer_orders_temp' to select each ordered pizza easier
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- 3. Create two new temporary tables 'extras_split' abd exclustions_split to separate toppings into multiple rows
DROP TABLE IF EXISTS extras_split;

CREATE TEMPORARY TABLE extras_split AS
SELECT
  c.record_id,
  TRIM(jt.extra_id) AS extra_id
FROM customer_orders_temp c
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(c.extras, ',', '","'), '"]'),
    '$[*]' COLUMNS (extra_id VARCHAR(4) PATH '$')
) AS jt;

SELECT * FROM extras_split; 

DROP TABLE IF EXISTS exclusions_split;

CREATE TEMPORARY TABLE exclusions_split AS
SELECT
  c.record_id,
  TRIM(jt.exclusion_id) AS exclusion_id
FROM customer_orders_temp c
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(c.exclusions, ',', '","'), '"]'),
    '$[*]' COLUMNS (exclusion_id VARCHAR(4) PATH '$')
) AS jt;

SELECT * FROM exclusions_split;

# Q1. What are the standard ingredients for each pizza?
SELECT 
p.pizza_id,
p.pizza_name,
GROUP_CONCAT(t.topping_name ORDER BY t.topping_name SEPARATOR ', ') AS ingredients
FROM pizza_names p
JOIN topping_split ts ON p.pizza_id = ts.pizza_id
JOIN pizza_toppings t ON ts.topping_id = t.topping_id
GROUP BY p.pizza_id, p.pizza_name;

# Q2. What was the most commonly added extra?
SELECT topping_name,
COUNT(topping_name) AS count
FROM extras_split
JOIN pizza_toppings
ON extra_id = topping_id
GROUP BY topping_name;

# Q3. What was the most common exclusion?
SELECT 
topping_name,
COUNT(topping_name) AS count
FROM exclusions_split
JOIN pizza_toppings
ON exclusion_id = topping_id
GROUP BY topping_name
ORDER BY count DESC;

/* Q4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */
-- CTE_extra
SELECT
e.record_id,
CONCAT('Extra ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) AS record_options
FROM extras_split e
JOIN pizza_toppings t ON e.extra_id = t.topping_id
GROUP BY e.record_id;

-- CTE_exclusion 
SELECT
e.record_id,
CONCAT('Exclusion ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) AS record_options
FROM exclusions_split e
JOIN pizza_toppings t ON e.exclusion_id = t.topping_id
GROUP BY e.record_id;

WITH CTE_extra AS (
SELECT
e.record_id,
CONCAT('Extra ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) AS record_options
FROM extras_split e
JOIN pizza_toppings t ON e.extra_id = t.topping_id
GROUP BY e.record_id
),

CTE_exclusion AS (
SELECT
e.record_id,
CONCAT('Exclusion ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) AS record_options
FROM exclusions_split e
JOIN pizza_toppings t ON e.exclusion_id = t.topping_id
GROUP BY e.record_id),

CTE_Union AS ( 
SELECT * FROM CTE_extra 
UNION
SELECT * FROM CTE_exclusion)

SELECT 
c.record_id, c.order_id,c.customer_id, c.pizza_id, c.order_time,
CONCAT_WS(' - ', p.pizza_name, GROUP_CONCAT(u.record_options SEPARATOR ' - ')) AS pizza_info
FROM CTE_Union u
RIGHT JOIN customer_orders_temp c
USING (record_id)
JOIN pizza_names p
USING (pizza_id)
GROUP BY 
c.record_id, 
c.order_id,
c.customer_id, 
c.pizza_id, 
c.order_time, 
p.pizza_name;

/* Generate an alphabetically ordered comma separated ingredient list 
for each pizza order from the customer_orders table 
and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

-- Step 1: Create base order info
DROP TABLE IF EXISTS temp_orders;

CREATE TEMPORARY TABLE temp_orders AS
SELECT 
  c.record_id,
  c.order_id,
  c.customer_id,
  c.pizza_id,
  c.order_time,
  c.extras,
  c.exclusions,
  p.pizza_name
FROM customer_orders_temp c
JOIN pizza_names p ON p.pizza_id = c.pizza_id;

-- Step 2: Create base_ingredients with '2x' logic
DROP TABLE IF EXISTS base_ingredients;

CREATE TEMPORARY TABLE base_ingredients AS
SELECT 
o.record_id,
o.order_id,
o.customer_id,
o.pizza_id,
o.order_time,
o.extras,
o.exclusions,
o.pizza_name,
ts.topping_id,
CASE 
WHEN e.extra_id IS NOT NULL THEN CONCAT('2x', pt.topping_name)
ELSE pt.topping_name
END AS topping
FROM temp_orders o
JOIN topping_split ts ON ts.pizza_id = o.pizza_id
JOIN pizza_toppings pt ON pt.topping_id = ts.topping_id
LEFT JOIN extras_split e ON e.record_id = o.record_id AND e.extra_id = ts.topping_id
LEFT JOIN exclusions_split ex ON ex.record_id = o.record_id AND ex.exclusion_id = ts.topping_id
WHERE ex.exclusion_id IS NULL;

-- Step 3: Create extra_only with toppings not in original pizza
DROP TABLE IF EXISTS extra_only;

CREATE TEMPORARY TABLE extra_only AS
SELECT 
o.record_id,
o.order_id,
o.customer_id,
o.pizza_id,
o.order_time,
o.extras,
o.exclusions,
o.pizza_name,
e.extra_id AS topping_id,
pt.topping_name AS topping
FROM temp_orders o
JOIN extras_split e ON e.record_id = o.record_id
JOIN pizza_toppings pt ON pt.topping_id = e.extra_id
LEFT JOIN topping_split ts ON ts.pizza_id = o.pizza_id AND ts.topping_id = e.extra_id
WHERE ts.topping_id IS NULL;

-- Step 4: Final merged result
SELECT 
record_id, 
order_id,
customer_id,
pizza_id, 
order_time,
extras,
exclusions,
CONCAT_WS(': ', pizza_name, GROUP_CONCAT(topping ORDER BY topping_id SEPARATOR ', ')) AS final_order
FROM (
SELECT * FROM base_ingredients
UNION ALL
SELECT * FROM extra_only
) AS all_ingredients
GROUP BY 
record_id, 
order_id,
customer_id,
pizza_id, 
order_time,
pizza_name,
extras,
exclusions;

# Q6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH frequency AS (
SELECT 
c.record_id,
t.topping_name,
CASE
WHEN t.topping_id IN (
SELECT extra_id 
FROM extras_split e
WHERE e.record_id = c.record_id)
THEN 2
WHEN t.topping_id IN (
SELECT exclusion_id 
FROM exclusions_split ex
WHERE ex.record_id = c.record_id)
THEN 0
ELSE 1 END AS times
FROM customer_orders_temp c
JOIN topping_split t
ON t.pizza_id = c.pizza_id
JOIN pizza_names p
ON p.pizza_id = c.pizza_id)

SELECT 
topping_name,
SUM(times) AS times
FROM frequency
GROUP BY topping_name
ORDER BY times DESC;


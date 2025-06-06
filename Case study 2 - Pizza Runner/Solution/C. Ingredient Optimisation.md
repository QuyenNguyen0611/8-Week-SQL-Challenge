# 🍕 Case Study #2: Pizza Runner

## C. Ingredient Optimisation

---

## 🧹 STEP 1: Data Cleaning

### 1. Create temporary 'pizza_recipes_temp' and 'topping_split' from 'pizza_recipes'
```sql
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
```
![Screen Shot 2025-06-06 at 15 54 59](https://github.com/user-attachments/assets/93a50b6f-17f0-47d9-94ca-e84d10e84936)

```sql
CREATE TEMPORARY TABLE topping_split AS
SELECT pizza_id, topping_id, topping_name
FROM pizza_recipes_temp
JOIN pizza_toppings USING(topping_id);
```
![Screen Shot 2025-06-06 at 15 55 55](https://github.com/user-attachments/assets/0ede76d1-e8dc-42eb-bec3-983ed76321c9)

### 2. Add an identity column 'record_id' to 'customer_orders_temp' to select each ordered pizza easier
```sql
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
```

### 3. Create two new temporary tables 'extras_split' abd exclustions_split to separate toppings into multiple rows
```sql
DROP TABLE IF EXISTS extras_split;

CREATE TEMPORARY TABLE extras_split AS
SELECT c.record_id, TRIM(jt.extra_id) AS extra_id
FROM customer_orders_temp c
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(c.extras, ',', '","'), '"]'),
  '$[*]' COLUMNS (extra_id VARCHAR(4) PATH '$')
) AS jt;

DROP TABLE IF EXISTS exclusions_split;

CREATE TEMPORARY TABLE exclusions_split AS
SELECT c.record_id, TRIM(jt.exclusion_id) AS exclusion_id
FROM customer_orders_temp c
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(c.exclusions, ',', '","'), '"]'),
  '$[*]' COLUMNS (exclusion_id VARCHAR(4) PATH '$')
) AS jt;
```
![Screen Shot 2025-06-06 at 15 57 06](https://github.com/user-attachments/assets/e0483df2-c7cf-4cd7-aaa8-ef847be2e239)

![Screen Shot 2025-06-06 at 15 57 28](https://github.com/user-attachments/assets/60040099-daa8-4a27-89a3-e24efc5b0ace)

---

## ✅ STEP 2: Answer Questions

### 1. What are the standard ingredients for each pizza?
```sql
SELECT 
  p.pizza_id,
  p.pizza_name,
  GROUP_CONCAT(t.topping_name ORDER BY t.topping_name SEPARATOR ', ') AS ingredients
FROM pizza_names p
JOIN topping_split ts ON p.pizza_id = ts.pizza_id
JOIN pizza_toppings t ON ts.topping_id = t.topping_id
GROUP BY p.pizza_id, p.pizza_name;
```
![Screen Shot 2025-06-06 at 15 42 32](https://github.com/user-attachments/assets/6053fb0e-73e0-4566-a246-80e4b4469a84)

### 2. What was the most commonly added extra?
```sql
SELECT topping_name, COUNT(topping_name) AS count
FROM extras_split
JOIN pizza_toppings ON extra_id = topping_id
GROUP BY topping_name;
```
![Screen Shot 2025-06-06 at 15 42 48](https://github.com/user-attachments/assets/8527fe5b-0e43-4e86-be61-6a3282316611)

### 3. What was the most common exclusion?
```sql
SELECT topping_name, COUNT(topping_name) AS count
FROM exclusions_split
JOIN pizza_toppings ON exclusion_id = topping_id
GROUP BY topping_name
ORDER BY count DESC;
```
![Screen Shot 2025-06-06 at 15 43 10](https://github.com/user-attachments/assets/91078d36-bc0f-4751-85e0-6c62b68bc9d3)

### 4. Generate an order item for each record in the 'customer_orders' table in the format of one of the following:

- 'Meat Lovers'
- 'Meat Lovers - Exclude Beef'
- 'Meat Lovers - Extra Bacon'
- 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
  
```sql
-- Create CTEs for extras and exclusions
WITH CTE_extra AS (
  SELECT e.record_id,
         CONCAT('Extra ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) AS record_options
  FROM extras_split e
  JOIN pizza_toppings t ON e.extra_id = t.topping_id
  GROUP BY e.record_id
),
CTE_exclusion AS (
  SELECT e.record_id,
         CONCAT('Exclusion ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) AS record_options
  FROM exclusions_split e
  JOIN pizza_toppings t ON e.exclusion_id = t.topping_id
  GROUP BY e.record_id
),
CTE_Union AS (
  SELECT * FROM CTE_extra
  UNION
  SELECT * FROM CTE_exclusion
)
SELECT 
  c.record_id, c.order_id, c.customer_id, c.pizza_id, c.order_time,
  CONCAT_WS(' - ', p.pizza_name, GROUP_CONCAT(u.record_options SEPARATOR ' - ')) AS pizza_info
FROM CTE_Union u
RIGHT JOIN customer_orders_temp c USING (record_id)
JOIN pizza_names p USING (pizza_id)
GROUP BY c.record_id, c.order_id, c.customer_id, c.pizza_id, c.order_time, p.pizza_name;
```
![Screen Shot 2025-06-06 at 15 44 59](https://github.com/user-attachments/assets/6ce832f6-ff30-4864-a99e-e34ccf43e816)

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the 'customer_orders' table and add a '2x' in front of any relevant ingredients
- For example: 'Meat Lovers: 2xBacon, Beef, ... , Salami'

```sql
SELECT 
  record_id, order_id, customer_id, pizza_id, order_time, extras, exclusions,
  CONCAT_WS(': ', pizza_name, GROUP_CONCAT(topping ORDER BY topping_id SEPARATOR ', ')) AS final_order
FROM (
  SELECT * FROM base_ingredients
  UNION ALL
  SELECT * FROM extra_only
) AS all_ingredients
GROUP BY record_id, order_id, customer_id, pizza_id, order_time, pizza_name, extras, exclusions;
```
![Screen Shot 2025-06-06 at 15 51 35](https://github.com/user-attachments/assets/0be6f5b3-b434-4b34-986a-26bbb633b5fa)

### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
```sql
WITH frequency AS (
  SELECT 
    c.record_id,
    t.topping_name,
    CASE
      WHEN t.topping_id IN (SELECT extra_id FROM extras_split e WHERE e.record_id = c.record_id) THEN 2
      WHEN t.topping_id IN (SELECT exclusion_id FROM exclusions_split ex WHERE ex.record_id = c.record_id) THEN 0
      ELSE 1
    END AS times
  FROM customer_orders_temp c
  JOIN topping_split t ON t.pizza_id = c.pizza_id
  JOIN pizza_names p ON p.pizza_id = c.pizza_id
)
SELECT topping_name, SUM(times) AS times
FROM frequency
GROUP BY topping_name
ORDER BY times DESC;
```
![Screen Shot 2025-06-06 at 15 51 55](https://github.com/user-attachments/assets/9e4debcf-4f62-4ff1-85d4-2973f04ab4c5)

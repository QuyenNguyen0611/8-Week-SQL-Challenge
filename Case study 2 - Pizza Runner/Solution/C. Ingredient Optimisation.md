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
| pizza_id | topping_id |
|----------|-------------|
| 1        | 1           |
| 1        | 2           |
| 1        | 3           |
| 1        | 4           |
| 1        | 5           |
| 1        | 6           |
| 1        | 8           |
| 1        | 10          |
| 2        | 4           |
| 2        | 6           |
| 2        | 7           |
| 2        | 9           |
| 2        | 11          |
| 2        | 12          |

```sql
CREATE TEMPORARY TABLE topping_split AS
SELECT pizza_id, topping_id, topping_name
FROM pizza_recipes_temp
JOIN pizza_toppings USING(topping_id);
```
| pizza_id | topping_id | topping_name   |
|----------|-------------|----------------|
| 1        | 1           | Bacon          |
| 1        | 2           | BBQ Sauce      |
| 1        | 3           | Beef           |
| 1        | 4           | Cheese         |
| 1        | 5           | Chicken        |
| 1        | 6           | Mushrooms      |
| 1        | 8           | Pepperoni      |
| 1        | 10          | Salami         |
| 2        | 4           | Cheese         |
| 2        | 6           | Mushrooms      |
| 2        | 7           | Onions         |
| 2        | 9           | Peppers        |
| 2        | 11          | Tomatoes       |
| 2        | 12          | Tomato Sauce   |

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
| record_id | extra_id |
|-----------|----------|
| 8         | 1        |
| 10        | 1        |
| 12        | 1        |
| 12        | 5        |
| 14        | 1        |
| 14        | 4        |


| record_id | exclusion_id |
|-----------|--------------|
| 5         | 4            |
| 6         | 4            |
| 7         | 4            |
| 12        | 4            |
| 14        | 2            |
| 14        | 6            |

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
| pizza_id | pizza_name | ingredients                                                                 |
|----------|-------------|------------------------------------------------------------------------------|
| 1        | Meatlovers  | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami       |
| 2        | Vegetarian  | Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                  |

### 2. What was the most commonly added extra?
```sql
SELECT topping_name, COUNT(topping_name) AS count
FROM extras_split
JOIN pizza_toppings ON extra_id = topping_id
GROUP BY topping_name;
```
| topping_name | count |
|--------------|-------|
| Bacon        | 4     |
| Cheese       | 1     |
| Chicken      | 1     |

### 3. What was the most common exclusion?
```sql
SELECT topping_name, COUNT(topping_name) AS count
FROM exclusions_split
JOIN pizza_toppings ON exclusion_id = topping_id
GROUP BY topping_name
ORDER BY count DESC;
```
| topping_name | count |
|--------------|-------|
| Cheese       | 4     |
| BBQ Sauce    | 1     |
| Mushrooms    | 1     |

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
| record_id | order_id | customer_id | pizza_id | order_time           | pizza_info                                                                 |
|-----------|----------|-------------|----------|----------------------|------------------------------------------------------------------------------|
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02  | Meatlovers                                                                   |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52  | Meatlovers                                                                   |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23  | Meatlovers                                                                   |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23  | Vegetarian                                                                   |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46  | Meatlovers - Exclusion Cheese                                               |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46  | Meatlovers - Exclusion Cheese                                               |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46  | Vegetarian - Exclusion Cheese                                               |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29  | Meatlovers - Extra Bacon                                                    |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13  | Vegetarian                                                                   |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29  | Vegetarian - Extra Bacon                                                    |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33  | Meatlovers                                                                   |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59  | Meatlovers - Extra Bacon, Chicken - Exclusion Cheese                        |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49  | Meatlovers                                                                   |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49  | Meatlovers - Extra Bacon, Cheese - Exclusion BBQ Sauce, Mushrooms          |

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
| record_id | order_id | customer_id | pizza_id | order_time           | extras  | exclusions | final_order                                                                 |
|-----------|----------|-------------|----------|----------------------|---------|------------|------------------------------------------------------------------------------|
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02  | NULL    | NULL       | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52  | NULL    | NULL       | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23  | NULL    | NULL       | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23  | NULL    | NULL       | Vegetarian: Tomatoes, Tomato Sauce, Cheese, Mushrooms, Onions, Peppers      |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46  | NULL    | 4          | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni   |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46  | NULL    | 4          | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni   |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46  | NULL    | 4          | Vegetarian: Tomatoes, Tomato Sauce, Mushrooms, Onions, Peppers              |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29  | 1       | NULL       | Meatlovers: 2xBacon, Salami, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13  | NULL    | NULL       | Vegetarian: Tomatoes, Tomato Sauce, Cheese, Mushrooms, Onions, Peppers      |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29  | 1       | NULL       | Vegetarian: Bacon, Tomatoes, Tomato Sauce, Cheese, Mushrooms, Onions, Peppers |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33  | NULL    | NULL       | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59  | 1,5     | 4          | Meatlovers: 2xBacon, Salami, BBQ Sauce, Beef, 2xChicken, Mushrooms, Pepperoni |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49  | NULL    | NULL       | Meatlovers: Bacon, Salami, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49  | 1,4     | 2,6        | Meatlovers: 2xBacon, Salami, Beef, 2xCheese, Chicken, Pepperoni             |

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
| topping_name  | times |
|---------------|-------|
| Bacon         | 13    |
| Mushrooms     | 13    |
| Cheese        | 11    |
| Chicken       | 11    |
| Beef          | 10    |
| Pepperoni     | 10    |
| Salami        | 10    |
| BBQ Sauce     | 9     |
| Onions        | 4     |
| Peppers       | 4     |
| Tomatoes      | 4     |
| Tomato Sauce  | 4     |

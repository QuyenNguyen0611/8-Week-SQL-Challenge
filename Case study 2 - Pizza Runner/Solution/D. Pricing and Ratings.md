# 🍕 Case Study #2: Pizza Runner

## D. Pricing and Ratings

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT
  SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS total_sales
FROM customer_orders_temp c
JOIN pizza_names p USING (pizza_id)
RIGHT JOIN runner_orders_temp r USING(order_id)
WHERE cancellation IS NULL;
```
| total_sales |
|-------------|
|138          |

---

### 2. What if there was a $1 charge for any pizza extras, and $2 for cheese?

```sql
-- Assuming @basecost = 138 (from Q1 result)
SELECT 
  @basecost + SUM(
    CASE 
      WHEN p.topping_name = 'Cheese' THEN 2
      ELSE 1 
    END
  ) AS updated_money
FROM extras_split e
JOIN pizza_toppings p ON e.extra_id = p.topping_id;
```
| updated_money|
|--------------|
|145           |

---

### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
  order_id INT,
  rating INT
);

INSERT INTO ratings (order_id, rating)
VALUES 
  (1, 4), (2, 5), (3, 5), (4, 3),
  (5, 4), (7, 4), (8, 3), (10, 5);

SELECT * FROM ratings;
```
| order_id | rating |
|----------|--------|
| 1        | 4      |
| 2        | 5      |
| 3        | 5      |
| 4        | 3      |
| 5        | 4      |
| 7        | 4      |
| 8        | 3      |
| 10       | 5      |

---

### 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- `customer_id`
- `order_id`
- `runner_id`
- `rating`
- `order_time`
- `pickup_time`
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

```sql
SELECT 
  c.customer_id,
  r.order_id, 
  o.runner_id, 
  r.rating,
  c.order_time,
  o.pickup_time, 
  TIMESTAMPDIFF(MINUTE, c.order_time, o.pickup_time) AS order_to_pickup_time,
  o.duration, 
  ROUND(AVG(60 * o.distance / o.duration), 2) AS avg_speed, 
  COUNT(c.order_id) AS pizza_count
FROM ratings r
JOIN runner_orders_temp o ON r.order_id = o.order_id
JOIN customer_orders_temp c ON c.order_id = r.order_id
GROUP BY 
  c.customer_id, r.order_id, o.runner_id, r.rating,
  c.order_time, o.pickup_time, o.duration;
```
| customer_id | order_id | runner_id | rating | order_time           | pickup_time          | order_to_pickup_time | duration | avg_speed | pizza_count |
|-------------|----------|-----------|--------|----------------------|----------------------|----------------------|----------|-----------|--------------|
| 101         | 1        | 1         | 4      | 2020-01-01 18:05:02  | 2020-01-01 18:15:34  | 10                   | 32       | 37.5      | 1            |
| 101         | 2        | 1         | 5      | 2020-01-01 19:00:52  | 2020-01-01 19:10:54  | 10                   | 27       | 44.44     | 1            |
| 102         | 3        | 1         | 5      | 2020-01-02 23:51:23  | 2020-01-03 00:12:37  | 21                   | 20       | 40.2      | 2            |
| 103         | 4        | 2         | 3      | 2020-01-04 13:23:46  | 2020-01-04 13:53:03  | 29                   | 40       | 35.1      | 3            |
| 104         | 5        | 3         | 4      | 2020-01-08 21:00:29  | 2020-01-08 21:10:57  | 10                   | 15       | 40        | 1            |
| 105         | 7        | 2         | 4      | 2020-01-08 21:20:29  | 2020-01-08 21:30:45  | 10                   | 25       | 60        | 1            |
| 102         | 8        | 2         | 3      | 2020-01-09 23:54:33  | 2020-01-10 00:15:02  | 20                   | 15       | 93.6      | 1            |
| 104         | 10       | 1         | 5      | 2020-01-11 18:34:49  | 2020-01-11 18:50:20  | 15                   | 10       | 60        | 2            |

---

### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
SELECT 
  @basecost AS revenue,
  ROUND(SUM(distance) * 0.3, 2) AS runner_paid,
  ROUND(@basecost - SUM(distance) * 0.3, 2) AS money_left
FROM runner_orders_temp;
```
| revenue | runner_paid | money_left |
|---------|-------------|-------------|
| 138     | 43.56       | 94.44       |


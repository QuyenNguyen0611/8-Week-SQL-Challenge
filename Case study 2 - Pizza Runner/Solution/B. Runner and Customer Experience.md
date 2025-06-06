
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
![Screen Shot 2025-06-06 at 14 49 25](https://github.com/user-attachments/assets/218e3ac7-5d06-4ad2-b764-d42baa99f44b)

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
![Screen Shot 2025-06-06 at 14 50 59](https://github.com/user-attachments/assets/5423aaeb-5f77-4c6e-bd86-449a429cb927)

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

![Screen Shot 2025-06-06 at 14 51 36](https://github.com/user-attachments/assets/0fb9dc9c-ed69-4f46-82a0-cc020003b7c9)

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
![Screen Shot 2025-06-06 at 14 52 03](https://github.com/user-attachments/assets/58325616-ffcf-4ebd-a9fb-a82049f1827f)

---

### 5. What was the difference between the longest and shortest delivery times?
```sql
SELECT (MAX(duration) - MIN(duration)) AS time_diff
FROM runner_orders_temp;
```
![Screen Shot 2025-06-06 at 14 52 25](https://github.com/user-attachments/assets/e5b78e33-22e9-4b35-90f9-af6ced150265)

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
![Screen Shot 2025-06-06 at 14 52 50](https://github.com/user-attachments/assets/e2784717-a6a2-4093-8a98-895e1b40f2b6)

---

### 7. What is the successful delivery percentage for each runner?
```sql
SELECT runner_id, 
       ROUND(COUNT(distance) * 100 / COUNT(order_id), 0) AS percentage_success
FROM runner_orders_temp
GROUP BY runner_id;
```
![Screen Shot 2025-06-06 at 14 53 27](https://github.com/user-attachments/assets/065acb90-8f9a-4c8a-a1fe-17d2b7502f30)

---

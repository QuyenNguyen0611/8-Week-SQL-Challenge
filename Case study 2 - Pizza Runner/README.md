# 🍕 Case Study #2 - Pizza Runner

## 📕 Table of Contents
- [🔐 Entity Relationship Diagram](#-entity-relationship-diagram)
- [❓ Case Study Questions](#-case-study-questions)
  - [A. Pizza Metrics](#a-pizza-metrics)
  - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
  - [C. Ingredient Optimisation](#c-ingredient-optimisation)
  - [D. Pricing and Ratings](#d-pricing-and-ratings)
  - [E. Bonus Questions](#e-bonus-questions)
- [🚀 My Solution](#-my-solution)

---

## 🔐 Entity Relationship Diagram

![Screen Shot 2025-06-06 at 22 15 44](https://github.com/user-attachments/assets/3920403c-39d2-45eb-b6d6-cf9cefe5056d)

---

## ❓ Case Study Questions

### A. Pizza Metrics  
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%202%20-%20Pizza%20Runner/Solution/A.%20Pizza%20Metrics.md)

1. How many pizzas were ordered?  
2. How many unique customer orders were made?  
3. How many successful orders were delivered by each runner?  
4. How many of each type of pizza was delivered?  
5. How many Vegetarian and Meatlovers were ordered by each customer?  
6. What was the maximum number of pizzas delivered in a single order?  
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?  
8. How many pizzas were delivered that had both exclusions and extras?  
9. What was the total volume of pizzas ordered for each hour of the day?  
10. What was the volume of orders for each day of the week?

---

### B. Runner and Customer Experience  
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%202%20-%20Pizza%20Runner/Solution/B.%20Runner%20and%20Customer%20Experience.md)

1. How many runners signed up for each 1 week period? (i.e. week starts `2021-01-01`)
2. What was the average time in minutes it took for each runner to arrive at the Pizza HQ to pickup the order?  
3. Is there any relationship between number of pizzas and preparation time?  
4. What was the average distance traveled per customer?  
5. What was the difference between the longest and shortest delivery times?  
6. What was the average speed for each runner?  
7. What is the successful delivery percentage for each runner?

---

### C. Ingredient Optimisation  
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%202%20-%20Pizza%20Runner/Solution/C.%20Ingredient%20Optimisation.md)

1. What are the standard ingredients for each pizza?  
2. What was the most commonly added extra?  
3. What was the most common exclusion?  
4. Generate an order item for each customer:
   - `Meat Lovers`
   - `Meat Lovers - Exclude Beef`
   - `Meat Lovers - Extra Bacon`
   - `Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers`  
5. Generate an alphabetically ordered ingredient list for each order, adding “2x” for relevant extras.
   - For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas?

---

### D. Pricing and Ratings  
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%202%20-%20Pizza%20Runner/Solution/D.%20Pricing%20and%20Ratings.md)

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

---

### E. Bonus Questions  
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%202%20-%20Pizza%20Runner/Solution/E.%20Bonus%20Question.md)

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an `INSERT` statement to demonstrate what would happen if a new `Supreme` pizza with all the toppings was added to the Pizza Runner menu?

---

## 🚀 My Solution

- [📜 View complete SQL scripts](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/tree/main/Case%20study%202%20-%20Pizza%20Runner/Syntax)
- [📊 View results](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/tree/main/Case%20study%202%20-%20Pizza%20Runner/Solution)

---

*Thanks to [@DataWithDanny](https://8weeksqlchallenge.com/) for this awesome case study challenge!* 🚀

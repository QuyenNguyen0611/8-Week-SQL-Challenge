# Case study 7: Balanced Tree Clothing Co.

## A. High Level Sales Analysis

#### Question 1. What are the top 3 products by total revenue before discount?
```sql
SELECT
product_name,
SUM(qty * s.price) AS revenue
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 3;
```

| product_name                 | revenue |
|------------------------------|----------|
| Blue Polo Shirt - Mens       | 217,683  |
| Grey Fashion Jacket - Womens | 209,304  |
| White Tee Shirt - Mens       | 152,000  |


#### Question 2. What is the total quantity, revenue and discount for each segment?
```sql
WITH line AS (
SELECT 
pd.segment_name,
s.qty,
s.price,
s.discount
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
)

SELECT
segment_name,
SUM(qty) AS total_qty,
SUM(qty * price) AS gross_revenue,
SUM(qty * price * discount/100.0) AS total_discount_amount,
SUM(qty * price * (1 - discount/100.0)) AS net_revenue,
ROUND(AVG(discount), 2) AS avg_discount_pct
FROM line
GROUP BY segment_name
ORDER BY net_revenue DESC;
```
| segment_name | total_qty | gross_revenue | total_discount_amount | net_revenue  | avg_discount_pct |
|---------------|-----------|----------------|------------------------|---------------|------------------|
| Shirt         | 11,265    | 406,143        | 49,594.27              | 356,548.73    | 12.19            |
| Jacket        | 11,385    | 366,983        | 44,277.46              | 322,705.54    | 12.05            |
| Socks         | 11,217    | 307,977        | 37,013.44              | 270,963.56    | 12.02            |
| Jeans         | 11,349    | 208,350        | 25,343.97              | 183,006.03    | 12.16            |


#### Question 3. What is the top selling product for each segment?
```sql
SELECT segment_name, product_name, total_qty
FROM (
	SELECT 
    pd.segment_name,
    pd.product_name,
    SUM(s.qty) AS total_qty,
    ROW_NUMBER() OVER (
      PARTITION BY pd.segment_name 
      ORDER BY SUM(s.qty) DESC
    ) AS rnk
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY pd.segment_name, pd.product_name
) AS t
WHERE rnk = 1;
```
| segment_name | product_name                 | total_qty |
|---------------|------------------------------|------------|
| Jacket        | Grey Fashion Jacket - Womens | 3,876      |
| Jeans         | Navy Oversized Jeans - Womens| 3,856      |
| Shirt         | Blue Polo Shirt - Mens       | 3,819      |
| Socks         | Navy Solid Socks - Mens      | 3,792      |


#### Question 4. What is the total quantity, revenue and discount for each category?
```sql
WITH CTE AS (
SELECT 
category_name,
qty, 
s.price * qty*(1 - discount/100) AS revenue, 
s.price * qty * discount/100 AS discount
FROM sales s
JOIN product_details pd 
ON s.prod_id = pd.product_id)

SELECT 
category_name,
SUM(qty) AS total_quantity,
ROUND(SUM(revenue),0) AS total_revenue,
ROUND(SUM(discount),0) AS total_discount
FROM CTE
GROUP BY category_name;
```

| category_name | total_quantity | total_revenue | total_discount |
|----------------|----------------|----------------|----------------|
| Womens         | 22,734         | 505,712        | 69,621         |
| Mens           | 22,482         | 627,512        | 86,608         |


#### Question 5. What is the top selling product for each category?
```sql
SELECT category_name, product_name, total_qty
FROM (
SELECT 
pd.category_name,
pd.product_name,
SUM(s.qty) AS total_qty,
ROW_NUMBER() OVER (
PARTITION BY pd.category_name ORDER BY SUM(s.qty) DESC
) AS rnk
FROM sales s
JOIN product_details pd 
ON s.prod_id = pd.product_id
GROUP BY pd.category_name, pd.product_name
) AS t;
```

| category_name | product_name                     | total_qty |
|----------------|----------------------------------|------------|
| Mens           | Blue Polo Shirt - Mens           | 3,819      |
| Mens           | White Tee Shirt - Mens           | 3,800      |
| Mens           | Navy Solid Socks - Mens          | 3,792      |
| Mens           | Pink Fluro Polkadot Socks - Mens | 3,770      |
| Mens           | White Striped Socks - Mens       | 3,655      |
| Mens           | Teal Button Up Shirt - Mens      | 3,646      |
| Womens         | Grey Fashion Jacket - Womens     | 3,876      |
| Womens         | Navy Oversized Jeans - Womens    | 3,856      |
| Womens         | Black Straight Jeans - Womens    | 3,786      |
| Womens         | Indigo Rain Jacket - Womens      | 3,757      |
| Womens         | Khaki Suit Jacket - Womens       | 3,752      |
| Womens         | Cream Relaxed Jeans - Womens     | 3,707      |


#### Question 6. What is the percentage split of revenue by product for each segment?
```sql
WITH prod_rev AS (
SELECT
p.segment_name,
p.product_name,
SUM(s.qty * s.price * (1 - s.discount/100.0)) AS revenue
FROM sales s
JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.segment_name, p.product_name
)

SELECT
segment_name,
product_name,
ROUND(
100.0 * revenue
/ SUM(revenue) OVER (PARTITION BY segment_name)
, 2) AS pct_of_product
FROM prod_rev
ORDER BY segment_name, pct_of_product DESC;
```

| segment_name | product_name                     | pct_of_product |
|---------------|----------------------------------|----------------|
| Jacket        | Grey Fashion Jacket - Womens     | 56.99          |
| Jacket        | Khaki Suit Jacket - Womens       | 23.57          |
| Jacket        | Indigo Rain Jacket - Womens      | 19.44          |
| Jeans         | Black Straight Jeans - Womens    | 58.14          |
| Jeans         | Navy Oversized Jeans - Womens    | 24.04          |
| Jeans         | Cream Relaxed Jeans - Womens     | 17.82          |
| Shirt         | Blue Polo Shirt - Mens           | 53.53          |
| Shirt         | White Tee Shirt - Mens           | 37.48          |
| Shirt         | Teal Button Up Shirt - Mens      | 8.99           |
| Socks         | Navy Solid Socks - Mens          | 44.24          |
| Socks         | Pink Fluro Polkadot Socks - Mens | 35.57          |
| Socks         | White Striped Socks - Mens       | 20.20          |


#### Question 7. What is the percentage split of revenue by segment for each category?
```sql
WITH prod_rev AS (
SELECT
p.segment_name,
p.category_name,
SUM(s.qty * s.price * (1 - s.discount/100.0)) AS revenue
FROM sales s
JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.segment_name, p.category_name
)

SELECT
segment_name,
category_name,
ROUND(
100.0 * revenue
/ SUM(revenue) OVER (PARTITION BY category_name)
, 2) AS pct_of_segment
FROM prod_rev
ORDER BY segment_name, pct_of_segment DESC;
```

| segment_name | category_name | pct_of_segment |
|---------------|----------------|----------------|
| Jacket        | Womens         | 63.81          |
| Jeans         | Womens         | 36.19          |
| Shirt         | Mens           | 56.82          |
| Socks         | Mens           | 43.18          |


#### Question 8. What is the percentage split of total revenue by category?
```sql
WITH prod_rev AS (
SELECT
p.category_name,
SUM(s.qty * s.price * (1 - s.discount/100.0)) AS revenue
FROM sales s
JOIN product_details p
ON s.prod_id = p.product_id
GROUP BY p.category_name
)

SELECT
category_name,
ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total_revenue
FROM prod_rev
ORDER BY pct_of_total_revenue DESC;
```

| category_name | pct_of_total_revenue |
|----------------|----------------------|
| Mens           | 55.37                |
| Womens         | 44.63                |


#### Question 9. What is the total transaction “penetration” for each product? 

(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql
WITH txn_counts AS (
  -- total transactions that bought each product
SELECT
s.prod_id,
COUNT(DISTINCT s.txn_id) AS txn_with_product
FROM sales s
GROUP BY s.prod_id
),
total_txn AS (
  -- total number of transactions overall
SELECT COUNT(DISTINCT txn_id) AS total_txn
FROM sales
)
SELECT
p.product_name,
ROUND(100.0 * t.txn_with_product / tt.total_txn, 2) AS penetration_pct
FROM txn_counts t
CROSS JOIN total_txn tt
JOIN product_details p
ON t.prod_id = p.product_id
ORDER BY penetration_pct DESC;
```

| product_name                     | penetration_pct |
|----------------------------------|-----------------|
| Navy Solid Socks - Mens          | 51.24           |
| Grey Fashion Jacket - Womens     | 51.00           |
| Navy Oversized Jeans - Womens    | 50.96           |
| White Tee Shirt - Mens           | 50.72           |
| Blue Polo Shirt - Mens           | 50.72           |
| Pink Fluro Polkadot Socks - Mens | 50.32           |
| Indigo Rain Jacket - Womens      | 50.00           |
| Khaki Suit Jacket - Womens       | 49.88           |
| Black Straight Jeans - Womens    | 49.84           |
| Cream Relaxed Jeans - Womens     | 49.72           |
| White Striped Socks - Mens       | 49.72           |
| Teal Button Up Shirt - Mens      | 49.68           |


#### Question 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
```sql
WITH presence AS (
  -- one row per (txn, product) with positive quantity
  SELECT txn_id, prod_id
  FROM sales
  GROUP BY txn_id, prod_id
  HAVING SUM(qty) > 0
)
SELECT
  pd1.product_name AS product_1,
  pd2.product_name AS product_2,
  pd3.product_name AS product_3,
  COUNT(DISTINCT a.txn_id) AS txn_count
FROM presence a
JOIN presence b
  ON a.txn_id = b.txn_id AND a.prod_id < b.prod_id
JOIN presence c
  ON a.txn_id = c.txn_id AND b.prod_id < c.prod_id
JOIN product_details pd1 ON pd1.product_id = a.prod_id
JOIN product_details pd2 ON pd2.product_id = b.prod_id
JOIN product_details pd3 ON pd3.product_id = c.prod_id
GROUP BY pd1.product_name, pd2.product_name, pd3.product_name
ORDER BY txn_count DESC
LIMIT 1;     -- change to 10 to see top 10 combos
```

| product_1           | product_2                     | product_3              | txn_count |
|----------------------|-------------------------------|------------------------|------------|
| White Tee Shirt - Mens | Grey Fashion Jacket - Womens | Teal Button Up Shirt - Mens | 352        |


### Insights

- Overall, sales are evenly distributed across products, with most items selling between 3,600–3,800 units. This indicates a balanced product portfolio where no single item dominates total sales.
- In terms of revenue, Blue Polo Shirt - Mens and Grey Fashion Jacket - Womens lead the category, showing that higher-priced apparel contributes more to overall revenue even when sales quantities are similar.
- Discount activity is consistent across products (around 12%), which suggests a uniform promotional strategy rather than selective discounting.
- Among segments, Shirts generate the highest revenue and quantity sold, followed by Jackets, Socks, and Jeans. This highlights Shirts as the company’s strongest-performing segment.
- Comparing categories, Mens products contribute 55% of total revenue, slightly outperforming Womens (45%), showing stronger engagement or higher prices in the menswear segment.
- The penetration rate for all products hovers around 50%, meaning both menswear and womenswear achieve comparable reach among transactions — a sign of good brand balance.
- The most common product combination purchased together is White Tee Shirt - Mens, Grey Fashion Jacket - Womens, and Teal Button Up Shirt - Mens (appearing together in 352 transactions).
→ This pattern suggests customers often mix both men’s and women’s items in one purchase, indicating possible cross-gender buying behavior (e.g., family or couple purchases).



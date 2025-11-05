# Case study 7: Balanced Tree Clothing Co.

## A. High Level Sales Analysis

#### Question 1: What was the total quantity sold for all products?

```sql
SELECT 
pd.product_name,
SUM(s.qty) as total_quantity
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_quantity DESC;
```

| product_name                     | total_quantity |
|----------------------------------|----------------|
| Grey Fashion Jacket - Womens     | 3876           |
| Navy Oversized Jeans - Womens    | 3856           |
| Blue Polo Shirt - Mens           | 3819           |
| White Tee Shirt - Mens           | 3800           |
| Navy Solid Socks - Mens          | 3792           |
| Black Straight Jeans - Womens    | 3786           |
| Pink Fluro Polkadot Socks - Mens | 3770           |
| Indigo Rain Jacket - Womens      | 3757           |
| Khaki Suit Jacket - Womens       | 3752           |
| Cream Relaxed Jeans - Womens     | 3707           |
| White Striped Socks - Mens       | 3655           |
| Teal Button Up Shirt - Mens      | 3646           |


#### Question 2. What is the total generated revenue for all products before discounts?
```sql
SELECT 
pd.product_name,
sum(s.price*qty) as total_sales
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_sales DESC;
```

| product_name                     | total_sales |
|----------------------------------|--------------|
| Blue Polo Shirt - Mens           | 217683       |
| Grey Fashion Jacket - Womens     | 209304       |
| White Tee Shirt - Mens           | 152000       |
| Navy Solid Socks - Mens          | 136512       |
| Black Straight Jeans - Womens    | 121152       |
| Pink Fluro Polkadot Socks - Mens | 109330       |
| Khaki Suit Jacket - Womens       | 86296        |
| Indigo Rain Jacket - Womens      | 71383        |
| White Striped Socks - Mens       | 62135        |
| Navy Oversized Jeans - Womens    | 50128        |
| Cream Relaxed Jeans - Womens     | 37070        |
| Teal Button Up Shirt - Mens      | 36460        |

#### Question 3. What was the total discount amount for all products? 
```sql
SELECT 
pd.product_name,
round(sum(s.price*qty*discount/100),0) as total_discount
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_discount DESC;
```

| product_name                     | total_discount |
|----------------------------------|----------------|
| Blue Polo Shirt - Mens           | 26819          |
| Grey Fashion Jacket - Womens     | 25392          |
| White Tee Shirt - Mens           | 18378          |
| Navy Solid Socks - Mens          | 16650          |
| Black Straight Jeans - Womens    | 14745          |
| Pink Fluro Polkadot Socks - Mens | 12952          |
| Khaki Suit Jacket - Womens       | 10243          |
| Indigo Rain Jacket - Womens      | 8643           |
| White Striped Socks - Mens       | 7411           |
| Navy Oversized Jeans - Womens    | 6136           |
| Cream Relaxed Jeans - Womens     | 4463           |
| Teal Button Up Shirt - Mens      | 4398           |


### Insights

- Overall, the sales quantities are quite consistent across all products, ranging between 3,600–3,800 units.
- However, total revenue varies significantly, mainly due to differences in product pricing — jackets and shirts generate higher revenue compared to socks or basic items.
- Products with higher revenue also tend to have higher total discounts, suggesting that promotions are focused on top-selling items to boost demand.
- A few products, such as Teal Button Up Shirt and Cream Relaxed Jeans, show low sales and low discounts, indicating they may be less popular and need review.





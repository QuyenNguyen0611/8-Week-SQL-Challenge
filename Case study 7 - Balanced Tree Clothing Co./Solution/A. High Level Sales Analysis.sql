# 1. What was the total quantity sold for all products?
SELECT 
pd.product_name,
SUM(s.qty) as total_quantity
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_quantity DESC;

# 2. What is the total generated revenue for all products before discounts?
SELECT 
pd.product_name,
sum(s.price*qty) as total_sales
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_sales DESC;

# 3. What was the total discount amount for all products? 
SELECT 
pd.product_name,
round(sum(s.price*qty*discount/100),0) as total_discount
FROM sales s
JOIN product_details pd
ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_discount DESC;
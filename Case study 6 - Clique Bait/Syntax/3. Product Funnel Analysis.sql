/* 3. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:

How many times was each product viewed? (event_type = 1)
How many times was each product added to cart? (event_type = 2)
How many times was each product added to a cart but not purchased (abandoned)?
How many times was each product purchased? (event_type = 3)
Additionally, create another table which further aggregates the data for the above points 
but this time for each product category instead of individual products.

Columns: 
table `page_hierarchy`: page_name -> product_name
view -> event_type = 1
added_to_cart -> event_type = 2
abandoned -> event_type = 2 & event_type != 2
purchased -> event_type = 3
*/
WITH CTE1 AS(
  SELECT 
    e.visit_id,
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_view, -- 1 for Page View
    SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_add -- 2 for Add Cart
  FROM events AS e
  JOIN page_hierarchy AS ph
    ON e.page_id = ph.page_id
    WHERE ph.product_id IS NOT NULL
  GROUP BY e.visit_id, ph.product_id, ph.page_name, ph.product_category), 

purchase_event AS(
  SELECT 
    DISTINCT visit_id
  FROM clique_bait.events
  WHERE event_type = 3),

combined_table AS(
SELECT 
c.visit_id, 
product_id, 
product_name, 
product_category, 
page_view, 
cart_add,
CASE WHEN p.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchased
FROM CTE1 c
LEFT JOIN purchase_event p
ON c.visit_id = p.visit_id)

/*SELECT 
product_name, 
product_category, 
SUM(page_view) AS views,
SUM(cart_add) AS cart_added,
SUM(CASE WHEN cart_add = 1 AND purchased = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchased = 1 THEN 1 ELSE 0 END) AS purchased
FROM combined_table
GROUP BY product_name, product_category;*/

SELECT 
product_category, 
SUM(page_view) AS views,
SUM(cart_add) AS cart_added,
SUM(CASE WHEN cart_add = 1 AND purchased = 0 THEN 1 ELSE 0 END) AS abandoned,
SUM(CASE WHEN cart_add = 1 AND purchased = 1 THEN 1 ELSE 0 END) AS purchased
FROM combined_table
GROUP BY product_category;
USE Clique_Bait; 

# 1. How many users are there?
SELECT COUNT(DISTINCT user_id) as total_users
FROM users;

# 2. How many cookies does each user have on average?
WITH cookie_count AS (
SELECT
user_id, 
COUNT(cookie_id) as count
FROM users
GROUP BY user_id
)

SELECT 
ROUND(AVG(count),0) as avg_cookie_each_user
FROM cookie_count;

# 3. What is the unique number of visits by all users per month?
SELECT 
month(event_time),
count(distinct visit_id)
FROM events 
GROUP BY month(event_time)
ORDER BY month(event_time);

# 4. What is the number of events for each event type?
SELECT 
event_type,
COUNT(event_type) as number_of_events
FROM events 
group by event_type;

# 5. What is the percentage of visits which have a purchase event?
SELECT 
100 * COUNT(DISTINCT e.visit_id)/
(SELECT COUNT(DISTINCT visit_id) FROM events) AS percentage_purchase
FROM events AS e
JOIN event_identifier AS ei
ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';

# 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
WITH checkout_purchase AS (
	SELECT 
	visit_id,
	MAX(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkout,
    MAX(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase
  FROM events
  GROUP BY visit_id
)
SELECT 
  CASE 
    WHEN SUM(checkout) = 0 THEN NULL
    ELSE ROUND(100 * (1 - SUM(purchase) / SUM(checkout)), 2)
  END AS percentage_checkout_view_with_no_purchase
FROM checkout_purchase;

# 7. What are the top 3 pages by number of views?
SELECT 
	p.page_name,
	COUNT(*) as number_of_views
FROM events e
JOIN page_hierarchy p
ON e.page_id = p.page_id
GROUP BY p.page_name
ORDER BY number_of_views DESC
LIMIT 3;

# 8. What is the number of views and cart adds for each product category?
-- event_type = 2 (Add to Cart) & event_type = 1 (Page View)
SELECT
	p.product_category,
	SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
	SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM events e
JOIN page_hierarchy p
ON e.page_id = p.page_id
WHERE p.product_category IS NOT NULL
GROUP BY p.product_category
ORDER BY page_views DESC;

# 9. What are the top 3 products by purchases?
SELECT
  p.page_name AS product,
  COUNT(*) AS purchases
FROM events e
JOIN page_hierarchy p
  ON p.page_id = e.page_id
WHERE e.event_type = 3    -- Purchase   
GROUP BY p.page_name
ORDER BY purchases DESC
LIMIT 3;




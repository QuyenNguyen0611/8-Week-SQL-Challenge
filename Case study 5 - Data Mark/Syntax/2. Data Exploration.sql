# 1. What day of the week is used for each week_date value?
SELECT DISTINCT
DISTINCT(DAYNAME((week_date))) AS week_day
FROM clean_weekly_sales;

# 2.What range of week numbers are missing from the dataset?
WITH RECURSIVE week_number_cte AS (
  SELECT 1 AS week_number
  UNION ALL
  SELECT week_number + 1 FROM week_number_cte WHERE week_number < 52
)
SELECT w.week_number
FROM week_number_cte AS w
LEFT JOIN (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE calendar_year = 2020
) s
  ON s.week_number = w.week_number
WHERE s.week_number IS NULL
ORDER BY w.week_number;


# 3. How many total transactions were there for each year in the dataset?
SELECT
  calendar_year,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

# 4. What is the total sales for each region for each month?
SELECT
  calendar_year,
  week_month AS month_number,
  region,
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year, week_month, region
ORDER BY calendar_year, week_month, region;

# 5. What is the total count of transactions for each platform?
SELECT
	platform,
	SUM(transactions) as transaction_count
FROM clean_weekly_sales
GROUP BY platform;

# 6. What is the percentage of sales for Retail vs Shopify for each month?
SELECT
	calendar_year,
	week_month,
	ROUND(100.0 * SUM(CASE WHEN platform='Retail'  THEN sales ELSE 0 END)/SUM(sales), 2) AS retail_pct,
	ROUND(100.0 * SUM(CASE WHEN platform='Shopify' THEN sales ELSE 0 END)/SUM(sales), 2) AS shopify_pct
FROM clean_weekly_sales
GROUP BY calendar_year, week_month
ORDER BY calendar_year, week_month;

# 7. What is the percentage of sales by demographic for each year in the dataset?
SELECT 
	calendar_year, 
	ROUND(100*SUM(CASE WHEN demographic = 'Families' THEN sales ELSE 0 END)/SUM(sales), 2) AS families_pct, 
	ROUND(100*SUM(CASE WHEN demographic = 'Couples' THEN sales ELSE 0 END)/SUM(sales), 2) AS couples_pct, 
	ROUND(100*SUM(CASE WHEN demographic = 'Unknown' THEN sales ELSE 0 END)/SUM(sales), 2) AS unknown_pct
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

# 8. Which age_band and demographic values contribute the most to Retail sales? 
SELECT
	age_band, 
	demographic, 
	SUM(sales) as total_sales, 
	ROUND(100* SUM(sales)/ 
		(SELECT SUM(sales) FROM clean_weekly_sales), 2) AS pct
FROM clean_weekly_sales
GROUP BY age_band, demographic
ORDER BY total_sales DESC;

# 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
# If not - how would you calculate it instead?

SELECT
	calendar_year,
	platform,
	ROUND(SUM(sales) / NULLIF(SUM(transactions), 0), 2) AS avg_transaction_size
FROM clean_weekly_sales
WHERE platform IN ('Retail','Shopify')
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;


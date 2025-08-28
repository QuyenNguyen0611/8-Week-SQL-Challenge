# 1. What is the total sales for the 4 weeks before and after 2020-06-15? 
# What is the growth or reduction rate in actual values and percentage of sales?

-- 20-06-15 is week_number 24
SELECT
  SUM(CASE WHEN week_number BETWEEN 20 AND 23 THEN sales ELSE 0 END) AS before_4,
  SUM(CASE WHEN week_number BETWEEN 24 AND 27 THEN sales ELSE 0 END) AS after_4,
  SUM(CASE WHEN week_number BETWEEN 24 AND 27 THEN sales ELSE 0 END)
    - SUM(CASE WHEN week_number BETWEEN 20 AND 23 THEN sales ELSE 0 END) AS change_abs,
  ROUND(
    100.0 *
    (
      SUM(CASE WHEN week_number BETWEEN 24 AND 27 THEN sales ELSE 0 END)
      - SUM(CASE WHEN week_number BETWEEN 20 AND 23 THEN sales ELSE 0 END)
    ) / NULLIF(SUM(CASE WHEN week_number BETWEEN 20 AND 23 THEN sales ELSE 0 END), 0)
  , 2) AS change_pct
FROM clean_weekly_sales
WHERE calendar_year = 2020;

# 2. What is the total sales for the 12 weeks before and after 2020-06-15? 
# What is the growth or reduction rate in actual values and percentage of sales?
-- 20-06-15 is week_number 24
SELECT
  SUM(CASE WHEN week_number BETWEEN 12 AND 23 THEN sales ELSE 0 END) AS before_12,
  SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN sales ELSE 0 END) AS after_12,
  SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN sales ELSE 0 END)
    - SUM(CASE WHEN week_number BETWEEN 12 AND 23 THEN sales ELSE 0 END) AS change_abs,
  ROUND(
    100.0 *
    (
      SUM(CASE WHEN week_number BETWEEN 24 AND 35 THEN sales ELSE 0 END)
      - SUM(CASE WHEN week_number BETWEEN 12 AND 23 THEN sales ELSE 0 END)
    ) / NULLIF(SUM(CASE WHEN week_number BETWEEN 12 AND 23 THEN sales ELSE 0 END), 0)
  , 2) AS change_pct
FROM clean_weekly_sales
WHERE calendar_year = 2020;

# 3. # How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- 4 WEEK PERIODS
WITH week_periods as (
SELECT
	calendar_year,
	week_number, 
	SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 20 AND 27
GROUP BY calendar_year, week_number),

before_after_changes AS
(SELECT 
	calendar_year,
	SUM( CASE WHEN week_number BETWEEN 20 AND 23 THEN total_sales ELSE 0 END) AS before_sales,
    SUM( CASE WHEN week_number BETWEEN 24 AND 27 THEN total_sales ELSE 0 END) AS after_sales
FROM week_periods
GROUP BY calendar_year)

SELECT 
calendar_year,
after_sales - before_sales AS sales_variance, 
ROUND((after_sales - before_sales)*100/before_sales, 2) AS change_pct
FROM before_after_changes
ORDER BY calendar_year;

-- 12 WEEK PERIODS
WITH week_periods as (
SELECT
	calendar_year,
	week_number, 
	SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 12 AND 35
GROUP BY calendar_year, week_number),

before_after_changes AS
(SELECT 
	calendar_year,
	SUM( CASE WHEN week_number BETWEEN 12 AND 23 THEN total_sales ELSE 0 END) AS before_sales,
    SUM( CASE WHEN week_number BETWEEN 24 AND 35 THEN total_sales ELSE 0 END) AS after_sales
FROM week_periods
GROUP BY calendar_year)

SELECT 
calendar_year,
after_sales - before_sales AS sales_variance, 
ROUND((after_sales - before_sales)*100/before_sales, 2) AS change_pct
FROM before_after_changes
ORDER BY calendar_year;


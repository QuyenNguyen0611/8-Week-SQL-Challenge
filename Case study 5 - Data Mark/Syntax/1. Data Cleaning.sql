DROP TABLE IF EXISTS clean_weekly_sales;

CREATE TABLE clean_weekly_sales AS
SELECT
STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_month,
YEAR(STR_TO_DATE(week_date, '%d/%m/%y'))  AS calendar_year,
region,
platform,
segment,
(CASE 
	WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults' 
    WHEN RIGHT(segment, 1) = '2' THEN 'Middle Age'
    WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees' 
    ELSE 'unknown' END) AS age_band,
(CASE 
	WHEN LEFT(segment, 1) = 'C' THEN 'Couples' 
    WHEN LEFT(segment, 1) = 'F' THEN 'Families'
    ELSE 'unknown' END) AS demographic,
transactions,
sales,
ROUND(sales / NULLIF(transactions, 0), 2) AS avg_transaction
FROM weekly_sales;

SELECT *
FROM clean_weekly_sales
;

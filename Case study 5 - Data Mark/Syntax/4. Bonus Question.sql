/* Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
region
platform
age_band
demographic
*/

WITH sales_periods AS (
    SELECT
        week_date,
        calendar_year,
        region,
        platform,
        age_band,
        demographic,
        SUM(sales) AS total_sales
    FROM clean_weekly_sales
    WHERE calendar_year = 2020
    GROUP BY week_date, calendar_year, region, platform, age_band, demographic
),
before_after AS (
    SELECT
        s.region,
        s.platform,
        s.age_band,
        s.demographic,
        CASE
            WHEN s.week_date BETWEEN DATE_SUB('2020-06-15', INTERVAL 12 WEEK) AND DATE_SUB('2020-06-15', INTERVAL 1 DAY)
                THEN 'Before'
            WHEN s.week_date BETWEEN '2020-06-15' AND DATE_ADD('2020-06-15', INTERVAL 12 WEEK)
                THEN 'After'
        END AS period_flag,
        SUM(s.total_sales) AS period_sales
    FROM sales_periods s
    WHERE s.week_date BETWEEN DATE_SUB('2020-06-15', INTERVAL 12 WEEK) AND DATE_ADD('2020-06-15', INTERVAL 12 WEEK)
    GROUP BY s.region, s.platform, s.age_band, s.demographic, period_flag
),
comparison AS (
    SELECT
        region,
        platform,
        age_band,
        demographic,
        MAX(CASE WHEN period_flag = 'Before' THEN period_sales END) AS sales_before,
        MAX(CASE WHEN period_flag = 'After' THEN period_sales END) AS sales_after
    FROM before_after
    GROUP BY region, platform, age_band, demographic
)
SELECT
    region,
    platform,
    age_band,
    demographic,
    sales_before,
    sales_after,
    (sales_after - sales_before) AS sales_change,
    ROUND(((sales_after - sales_before) / NULLIF(sales_before,0)) * 100, 2) AS pct_change
FROM comparison
ORDER BY sales_change ASC;  -- most negative first




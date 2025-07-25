# 🥑 Case Study #3: Foodie-Fi

## A. Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Table: Sample of `subscriptions` table
| customer_id | plan_id | start_date  |
|-------------|---------|-------------|
| 1           | 0       | 2020-08-01  |
| 1           | 1       | 2020-08-08  |
| 2           | 0       | 2020-09-20  |
| 2           | 3       | 2020-09-27  |
| 11          | 0       | 2020-11-19  |
| 11          | 4       | 2020-11-26  |
| 13          | 0       | 2020-12-15  |
| 13          | 1       | 2020-12-22  |
| 13          | 2       | 2021-03-29  |
| 15          | 0       | 2020-03-17  |
| 15          | 2       | 2020-03-24  |
| 15          | 4       | 2020-04-29  |
| 16          | 0       | 2020-05-31  |
| 16          | 1       | 2020-06-07  |
| 16          | 3       | 2020-10-21  |
| 18          | 0       | 2020-07-06  |
| 18          | 2       | 2020-07-13  |
| 19          | 0       | 2020-06-22  |
| 19          | 2       | 2020-06-29  |
| 19          | 3       | 2020-08-29  |

**Answer:** 

```sql
SELECT
customer_id,
p.plan_id,
plan_name,
start_date
FROM plans p 
JOIN subscriptions s 
ON p.plan_id = s.plan_id
WHERE customer_id IN (1,2,11,13,15,16,18,19);
```

**Result:**
| customer_id | plan_id | plan_name      | start_date  |
|-------------|---------|----------------|-------------|
| 1           | 0       | trial          | 2020-08-01  |
| 1           | 1       | basic monthly  | 2020-08-08  |
| 2           | 0       | trial          | 2020-09-20  |
| 2           | 3       | pro annual     | 2020-09-27  |
| 11          | 0       | trial          | 2020-11-19  |
| 11          | 4       | churn          | 2020-11-26  |
| 13          | 0       | trial          | 2020-12-15  |
| 13          | 1       | basic monthly  | 2020-12-22  |
| 13          | 2       | pro monthly    | 2021-03-29  |
| 15          | 0       | trial          | 2020-03-17  |
| 15          | 2       | pro monthly    | 2020-03-24  |
| 15          | 4       | churn          | 2020-04-29  |
| 16          | 0       | trial          | 2020-05-31  |
| 16          | 1       | basic monthly  | 2020-06-07  |
| 16          | 3       | pro annual     | 2020-10-21  |
| 18          | 0       | trial          | 2020-07-06  |
| 18          | 2       | pro monthly    | 2020-07-13  |
| 19          | 0       | trial          | 2020-06-22  |
| 19          | 2       | pro monthly    | 2020-06-29  |
| 19          | 3       | pro annual     | 2020-08-29  |

Based on the results above, I have selected three customers to focus on and will now share their onboarding journey.

### Customer 1: 
This customer started out with a free trial on August 1, 2020. After that, they decided to continue by subscribing to the Basic Monthly plan on August 8.
| customer_id | plan_id | plan_name      | start_date  |
|-------------|---------|----------------|-------------|
| 1           | 0       | trial          | 2020-08-01  |
| 1           | 1       | basic monthly  | 2020-08-08  |

### Customer 11: 
Customer 11 started with a free trial on November 19, 2020, but chose not to continue with any subscription after it ended.

| customer_id | plan_id | plan_name      | start_date  |
|-------------|---------|----------------|-------------|
| 11          | 0       | trial          | 2020-11-19  |
| 11          | 4       | churn          | 2020-11-26  |

### Customer 13: 
Customer 13 began with a free trial on December 15, 2020. Then, they upgraded to the Basic Monthly plan. On March 29, 2021, they switched to the Pro Monthly plan, suggesting growing engagement over time.

| customer_id | plan_id | plan_name      | start_date  |
|-------------|---------|----------------|-------------|
| 13          | 0       | trial          | 2020-12-15  |
| 13          | 1       | basic monthly  | 2020-12-22  |
| 13          | 2       | pro monthly    | 2021-03-29  |

# Case study 7: Balanced Tree Clothing Co.

## B. Transaction Analysis

#### Question 1: How many unique transactions were there?
```sql
SELECT 
COUNT(distinct txn_id) as total_transactions
FROM sales;
```

|total_transactions |
|-------------------|
|2500               |

#### Question 2. What is the average unique products purchased in each transaction?
```sql
WITH prod_txn AS (
SELECT 
count(distinct prod_id) AS prod_count,
txn_id
FROM sales
GROUP BY txn_id)

SELECT 
ROUND(AVG(prod_count),0) AS avg_unique_products_per_transaction
FROM prod_txn;
```
| avg_unique_products_per_transaction |
|-------------------------------------|
| 6                                   |

#### Question 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
```sql
WITH txn_rev AS (
SELECT 
txn_id,
sum(qty*price*(100 - discount)/100) as revenue
FROM sales
GROUP BY txn_id)
,
ranked AS (
SELECT 
revenue,
ROW_NUMBER() OVER (ORDER BY revenue) AS rn,
COUNT(*) OVER () AS total_rows
FROM txn_rev
)

SELECT
ROUND(MAX(CASE WHEN rn <= 0.25 * total_rows THEN revenue END),0) AS p25,
ROUND(MAX(CASE WHEN rn <= 0.50 * total_rows THEN revenue END),0) AS p50,
ROUND(MAX(CASE WHEN rn <= 0.75 * total_rows THEN revenue END),0) AS p75
FROM ranked;
```

|  p25 |  p50 | p75 |
|------|------|-----|
| 326  | 441  | 573 |


#### Question 4. What is the average discount value per transaction?
```sql
SELECT 
txn_id,
ROUND(AVG(discount), 2) AS avg_discount_per_transaction
FROM sales
GROUP BY txn_id
ORDER BY avg_discount_per_transaction DESC;
```
|  txn_id | avg_discount_per_transaction |
|---------|------------------------------|
| 034601  | 24.00                        |
| 030b14  | 24.00                        |
|...      | ...                          |
| e84c09  | 15.00                        |
| c1e506  | 15.00                        |                       

#### Question 5. What is the percentage split of all transactions for members vs non-members?
```sql
WITH count AS(
SELECT 
SUM(CASE WHEN member = 1 THEN 1 END) AS members,
SUM(CASE WHEN member = 0 THEN 1 END) AS non_members
FROM sales)

SELECT 
ROUND(members*100/(members+non_members),2) AS pct_members,
ROUND(non_members*100/(members+non_members),2) AS pct_non_members
FROM count;
```

|  pct_members | pct_non_members |
|--------------|-----------------|
| 60.03        | 39.97           |


#### Question 6. What is the average revenue for member transactions and non-member transactions?
```sql
WITH txn_rev AS (
SELECT
txn_id,
member,
SUM(qty * price * (100 - discount) / 100.0) AS revenue
FROM sales
GROUP BY txn_id, member
)

SELECT
ROUND(AVG(CASE WHEN member = 1 THEN revenue END),0) AS member_rev,
ROUND(AVG(CASE WHEN member = 0 THEN revenue END),0) AS non_member_rev
FROM txn_rev;
```

| member_rev | non_member_rev |
|------------|----------------|
| 454        | 452            |

### Insight

Overall, the transaction data shows strong and balanced customer activity. With 2,500 unique transactions and an average of six products per purchase, customers tend to buy a variety of items each time. Most transactions generate moderate revenue, typically between $326 and $573, with discounts averaging around 15–24%. About 60% of transactions come from members, confirming the success of the membership program in driving repeat sales. However, the average spending per transaction is almost the same for both members and non-members, suggesting that membership mainly boosts purchase frequency rather than transaction value.


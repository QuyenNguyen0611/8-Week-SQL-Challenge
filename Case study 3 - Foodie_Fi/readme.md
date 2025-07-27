# 🥑 Case Study #3: Foodie-Fi

## 📕 Table of Contents
- [🔐 Entity Relationship Diagram](#-entity-relationship-diagram)
- [❓ Case Study Questions](#-case-study-questions)
  - [A. Customer Journey](#a-customer-journey)
  - [B. Data Analysis Questions](#b-data-analysis-questions)
  - [C. Challenge Payment Question](#c-challenge-payment-question)
- [🚀 My Solution](#-my-solution)

## 🔐 Entity Relationship Diagram
<img width="751" height="362" alt="Screen Shot 2025-07-27 at 17 02 08" src="https://github.com/user-attachments/assets/c28fb53b-4ef1-417c-9314-f430b6cd0e80" />

Foodie-Fi’s data is structured around two core tables:
- `plans`: Contains available subscription plans
- `subscriptions`: Tracks customer activity and plan transitions

## ❓ Case Study Questions

### A. Customer Journey
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%203%20-%20Foodie_Fi/Solution/A.%20Customer%20Journey.md)
Using the sample subscription records of 8 customers, describe their onboarding path in a concise format:
- Did they start with a trial?
- Did they upgrade or churn?
- How quickly did they make decisions?

### B. Data Analysis Questions
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%203%20-%20Foodie_Fi/Solution/B.%20Data%20Analysis%20Questions.md)
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start dates (grouped by start of the month)?
3. What plan start dates occurred after 2020? Group by plan_name.
4. How many customers have churned? Show the percentage (rounded to 1 decimal).
5. How many customers churned right after their trial? What percentage is this (rounded to nearest whole number)?
6. What are the counts and percentages of customer plan types after trial?
7. What was the plan distribution on 2020-12-31?
8. How many customers upgraded to an annual plan in 2020?
9. What is the average number of days it took customers to upgrade to annual from their start date?
10. Break the upgrade times into 30-day buckets (e.g., 0–30, 31–60...)
11. How many customers downgraded from Pro Monthly to Basic Monthly in 2020?

### C. Challenge Payment Question
[📄 View my solution](https://github.com/QuyenNguyen0611/8-Week-SQL-Challenge/blob/main/Case%20study%203%20-%20Foodie_Fi/Solution/C.%20Challenge%20Payment%20Question.md)

Create a payments_2020 table that reflects actual billing behavior:

**Requirements:**
- Monthly payments are billed on the same day each month as the plan’s start_date.
- Upgrades from Basic → Pro (Monthly/Annual) deduct the Basic plan’s cost from the Pro charge.
- Upgrades from Pro Monthly → Pro Annual are billed at the end of the current billing cycle.
- Churned customers make no payments after their plan ends.




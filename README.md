# Cohort Analysis using SQL (Snowflake)

## 🎯 Purpose of Analysis

The overarching purpose of this project lies in leveraging cohort analysis across multiple dimensions: order level, customer level, and revenue analysis. Through these distinct but interconnected analyses, the project aims to uncover crucial insights that illuminate customer behavior, retention dynamics, and revenue patterns.

**Cohort Analysis on Order Level:** By categorizing customers into cohorts based on their initial purchase month, this analysis delves into understanding the distribution of invoices within these cohorts over subsequent months. This helps identify trends in transaction volumes, revealing whether certain cohorts exhibit sustained engagement or diminishing activity.

**Cohort Analysis on Customer Level:** Focusing on customer retention, this analysis tracks how cohorts evolve over time in terms of customer count. By observing how many customers remain active in each cohort, businesses can gauge the effectiveness of their retention strategies and pinpoint areas for improvement.

**Cohort Analysis on Number of Revenues:** Examining revenue generation, this analysis investigates how revenue changes across different cohorts over successive months. By analyzing revenue trends, businesses can identify cohorts that contribute significantly to revenue growth and those that require interventions to enhance their value.

Through these comprehensive analyses, businesses gain insights into customer lifetime value, retention dynamics, and revenue patterns. These insights pave the way for data-driven strategies that optimize engagement, retention, and revenue, ultimately fostering business growth and customer satisfaction.

---

## 📌 Project Overview
This project performs **Cohort Analysis** on a retail dataset using **Snowflake SQL**.
The analysis focuses on customer retention and order-level cohort tracking
based on their first purchase month.

The dataset is downloaded from [Kaggle](https://www.kaggle.com/datasets/jihyeseo/online-retail-data-set-from-uci-ml-repo).

---

## 🛠️ Tools Used
- Snowflake SQL
- GitHub

---

## 📂 Dataset
| Column | Type | Description |
|--------|------|-------------|
| InvoiceNo | varchar(10) | Unique invoice number |
| StockCode | varchar(20) | Product stock code |
| Description | varchar(100) | Product description |
| Quantity | number(8,2) | Quantity purchased |
| InvoiceDate | varchar(25) | Date and time of purchase |
| UnitPrice | number(8,2) | Price per unit |
| CustomerID | number(10) | Unique customer ID |
| Country | varchar(25) | Country of the customer |

---

## 💻 Database & Table Setup

```sql
-- Create a new database named SALES
CREATE DATABASE SALES;

-- Create a new schema named COHORT_ANALYSIS
CREATE SCHEMA COHORT_ANALYSIS;

-- Switch to using the COHORT_ANALYSIS schema
USE SCHEMA COHORT_ANALYSIS;

-- Create a table named RETAIL to store retail data
CREATE OR REPLACE TABLE RETAIL (
    InvoiceNo varchar(10),
    StockCode varchar(20),
    Description varchar(100),
    Quantity number(8,2),
    InvoiceDate varchar(25),
    UnitPrice number(8,2),
    CustomerID number(10),
    Country varchar(25)
);

SELECT * FROM RETAIL LIMIT 5;
```

### Results of the query
| INVOICENO | STOCKCODE | DESCRIPTION | QUANTITY | INVOICEDATE | UNITPRICE | CUSTOMERID | COUNTRY |
|-----------|-----------|-------------|----------|-------------|-----------|------------|---------|
| 536365 | 85123A | WHITE HANGING HEART T-LIGHT HOLDER | 6 | 1/12/10 8:26 | 2.55 | 17850 | United Kingdom |
| 536366 | 22633 | HAND WARMER UNION JACK | 6 | 1/12/10 8:28 | 1.85 | 17850 | United Kingdom |
| 536367 | 84879 | ASSORTED COLOUR BIRD ORNAMENT | 32 | 1/12/10 8:34 | 1.69 | 13047 | United Kingdom |
| 536368 | 22960 | JAM MAKING SET WITH JARS | 6 | 1/12/10 8:34 | 4.25 | 13047 | United Kingdom |
| 536369 | 21756 | BATH BUILDING BLOCK WORD | 3 | 1/12/10 8:35 | 5.95 | 13047 | United Kingdom |

---

## 📊 Cohort Analysis on Order Level

The first cohort analysis focuses on order-level cohort analysis. We calculate the number of invoices for each cohort of customers based on their first purchase month.

```sql
-- Step 1: Create CTE1 to prepare data
WITH CTE1 AS (
    SELECT 
        InvoiceNo, CUSTOMERID, 
        to_date(INVOICEDATE, 'DD/MM/YY HH24:MI') AS INVOICEDATE, 
        ROUND(QUANTITY * UNITPRICE, 2) AS REVENUE
    FROM RETAIL
    WHERE CUSTOMERID IS NOT NULL
),

-- Step 2: Create CTE2 to calculate purchase and first purchase months
CTE2 AS (
    SELECT InvoiceNo, CUSTOMERID, INVOICEDATE, 
        DATE_TRUNC('MONTH', INVOICEDATE) AS PURCHASE_MONTH,
        DATE_TRUNC('MONTH', MIN(INVOICEDATE) OVER (PARTITION BY CUSTOMERID ORDER BY INVOICEDATE)) AS FIRST_PURCHASE_MONTH,
        REVENUE
    FROM CTE1
),

-- Step 3: Create CTE3 to determine cohort months
CTE3 AS (
    SELECT InvoiceNo, FIRST_PURCHASE_MONTH,
        CONCAT('Month_', datediff('MONTH', FIRST_PURCHASE_MONTH, PURCHASE_MONTH)) AS COHORT_MONTH
    FROM CTE2
)

-- Step 4: Pivot and count invoices by cohort months
SELECT *
FROM CTE3
PIVOT (
    COUNT(InvoiceNo) FOR COHORT_MONTH IN (
        'Month_0', 'Month_1', 'Month_2', 'Month_3', 'Month_4', 'Month_5',
        'Month_6', 'Month_7', 'Month_8', 'Month_9', 'Month_10', 'Month_11', 'Month_12'
    )
)
ORDER BY FIRST_PURCHASE_MONTH;
```

### Results of the query
| FIRST_PURCHASE_MONTH | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|----------------------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|----------|
| 2010-12-01 | 1,701 | 677 | 573 | 747 | 610 | 799 | 732 | 686 | 653 | 791 | 760 | 1,130 | 395 |
| 2011-01-01 | 545 | 148 | 181 | 148 | 233 | 195 | 176 | 172 | 184 | 233 | 277 | 89 | 0 |
| 2011-02-01 | 473 | 135 | 113 | 162 | 141 | 131 | 123 | 164 | 134 | 187 | 40 | 0 | 0 |
| 2011-03-01 | 542 | 122 | 176 | 149 | 141 | 121 | 157 | 160 | 220 | 45 | 0 | 0 | 0 |
| 2011-04-01 | 385 | 109 | 91 | 78 | 83 | 91 | 94 | 120 | 32 | 0 | 0 | 0 | 0 |
| 2011-05-01 | 365 | 93 | 63 | 70 | 93 | 87 | 113 | 34 | 0 | 0 | 0 | 0 | 0 |
| 2011-06-01 | 296 | 70 | 57 | 91 | 79 | 129 | 30 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-07-01 | 235 | 50 | 59 | 55 | 82 | 25 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-08-01 | 203 | 59 | 70 | 69 | 26 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-09-01 | 379 | 126 | 157 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-10-01 | 453 | 165 | 56 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-11-01 | 425 | 55 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-12-01 | 45 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

---

## 👥 Cohort Analysis / Customer Retention Analysis on Customer Level

This analysis determines the count of distinct customers within each cohort, categorized by their first purchase month and subsequent months.

```sql
-- Step 1: Create CTE1 to prepare data
WITH CTE1 AS (
    SELECT 
        InvoiceNo, CUSTOMERID, 
        to_date(INVOICEDATE, 'DD/MM/YY HH24:MI') AS INVOICEDATE, 
        ROUND(QUANTITY * UNITPRICE, 2) AS REVENUE
    FROM RETAIL
    WHERE CUSTOMERID IS NOT NULL
),

-- Step 2: Create CTE2 to calculate purchase and first purchase months
CTE2 AS (
    SELECT InvoiceNo, CUSTOMERID, INVOICEDATE, 
        DATE_TRUNC('MONTH', INVOICEDATE) AS PURCHASE_MONTH,
        DATE_TRUNC('MONTH', MIN(INVOICEDATE) OVER (PARTITION BY CUSTOMERID ORDER BY INVOICEDATE)) AS FIRST_PURCHASE_MONTH,
        REVENUE
    FROM CTE1
),

-- Step 3: Create CTE3 to determine cohort months
CTE3 AS (
    SELECT CUSTOMERID, FIRST_PURCHASE_MONTH,
        CONCAT('Month_', datediff('MONTH', FIRST_PURCHASE_MONTH, PURCHASE_MONTH)) AS COHORT_MONTH
    FROM CTE2
)

-- Final Query: Count distinct customers in each cohort for subsequent months
SELECT FIRST_PURCHASE_MONTH as Cohort,
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_0', CUSTOMERID, NULL))) as "Month_0",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_1', CUSTOMERID, NULL))) as "Month_1",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_2', CUSTOMERID, NULL))) as "Month_2",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_3', CUSTOMERID, NULL))) as "Month_3",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_4', CUSTOMERID, NULL))) as "Month_4",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_5', CUSTOMERID, NULL))) as "Month_5",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_6', CUSTOMERID, NULL))) as "Month_6",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_7', CUSTOMERID, NULL))) as "Month_7",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_8', CUSTOMERID, NULL))) as "Month_8",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_9', CUSTOMERID, NULL))) as "Month_9",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_10', CUSTOMERID, NULL))) as "Month_10",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_11', CUSTOMERID, NULL))) as "Month_11",
    COUNT(DISTINCT(IFF(COHORT_MONTH='Month_12', CUSTOMERID, NULL))) as "Month_12"
FROM CTE3
GROUP BY FIRST_PURCHASE_MONTH
ORDER BY FIRST_PURCHASE_MONTH;
```

### Results of the query
| COHORT | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|----------|
| 2010-12-01 | 945 | 358 | 313 | 367 | 340 | 375 | 360 | 336 | 333 | 371 | 354 | 473 | 260 |
| 2011-01-01 | 419 | 100 | 118 | 101 | 138 | 126 | 109 | 108 | 129 | 145 | 152 | 63 | 0 |
| 2011-02-01 | 380 | 93 | 73 | 106 | 102 | 91 | 96 | 108 | 97 | 119 | 35 | 0 | 0 |
| 2011-03-01 | 437 | 84 | 111 | 96 | 102 | 77 | 114 | 105 | 126 | 37 | 0 | 0 | 0 |
| 2011-04-01 | 299 | 68 | 65 | 63 | 62 | 72 | 69 | 78 | 25 | 0 | 0 | 0 | 0 |
| 2011-05-01 | 278 | 66 | 48 | 48 | 60 | 68 | 74 | 27 | 0 | 0 | 0 | 0 | 0 |
| 2011-06-01 | 234 | 49 | 44 | 64 | 58 | 79 | 24 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-07-01 | 191 | 40 | 39 | 43 | 51 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-08-01 | 169 | 42 | 42 | 43 | 23 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-09-01 | 298 | 89 | 98 | 35 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-10-01 | 350 | 93 | 46 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-11-01 | 321 | 43 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-12-01 | 41 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

---

## 💰 Cohort Analysis on Revenue Level

This analysis examines how revenue generated by different customer cohorts changes over time.

```sql
-- Creating CTE1 to calculate revenue from valid transactions
WITH CTE1 AS (
    SELECT 
        CUSTOMERID,
        to_date(INVOICEDATE, 'DD/MM/YY HH24:MI') AS INVOICEDATE,
        ROUND(QUANTITY * UNITPRICE, 0) AS REVENUE
    FROM RETAIL
    WHERE CUSTOMERID IS NOT NULL
        AND INVOICENO IS NOT NULL
        AND QUANTITY > 0
        AND UNITPRICE > 0
),

-- Creating CTE2 to calculate cohort-related metrics
CTE2 AS (
    SELECT 
        CUSTOMERID, 
        INVOICEDATE, 
        DATE_TRUNC('MONTH', INVOICEDATE) AS PURCHASE_MONTH,
        DATE_TRUNC('MONTH', MIN(INVOICEDATE) OVER (PARTITION BY CUSTOMERID ORDER BY INVOICEDATE)) AS FIRST_PURCHASE_MONTH,
        REVENUE
    FROM CTE1
),

-- Creating CTE3 for further analysis
CTE3 AS (
    SELECT 
        FIRST_PURCHASE_MONTH AS Cohort,
        CONCAT('Month_', datediff('MONTH', FIRST_PURCHASE_MONTH, PURCHASE_MONTH)) AS COHORT_MONTH,
        REVENUE
    FROM CTE2
)

-- Generating the cohort analysis table with pivot and summing revenue
SELECT *
FROM CTE3
PIVOT (
    SUM(REVENUE) FOR COHORT_MONTH IN (
        'Month_0', 'Month_1', 'Month_2', 'Month_3', 'Month_4', 'Month_5',
        'Month_6', 'Month_7', 'Month_8', 'Month_9', 'Month_10', 'Month_11', 'Month_12'
    )
)
ORDER BY Cohort;
```

### Results of the query
| COHORT | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|--------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|----------|
| 2010-12-01 | 66,676 | 25,436 | 25,398 | 32,723 | 24,483 | 33,929 | 34,524 | 24,225 | 22,651 | 40,927 | 55,317 | 53,117 | 18,593 |
| 2011-01-01 | 18,890 | 4,158 | 5,732 | 4,638 | 8,181 | 5,995 | 5,237 | 5,611 | 5,954 | 7,679 | 11,947 | 3,417 | 0 |
| 2011-02-01 | 17,899 | 3,783 | 6,407 | 6,048 | 2,141 | 3,212 | 4,218 | 5,130 | 6,637 | 7,497 | 2,033 | 0 | 0 |
| 2011-03-01 | 14,855 | 3,884 | 6,641 | 4,626 | 3,045 | 3,109 | 6,268 | 7,160 | 9,064 | 2,190 | 0 | 0 | 0 |
| 2011-04-01 | 9,721 | 3,012 | 2,944 | 2,041 | 2,101 | 1,798 | 2,185 | 3,608 | 460 | 0 | 0 | 0 | 0 |
| 2011-05-01 | 12,767 | 2,901 | 2,812 | 2,620 | 2,132 | 2,484 | 3,032 | 890 | 0 | 0 | 0 | 0 | 0 |
| 2011-06-01 | 9,303 | 2,560 | 1,198 | 2,225 | 3,465 | 6,772 | 650 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-07-01 | -632 | 1,142 | 1,160 | 938 | 1,933 | 559 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-08-01 | 4,994 | 62 | -783 | -2,036 | -707 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-09-01 | 12,110 | 1,998 | 3,212 | 1,003 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-10-01 | 9,670 | 3,682 | 2,202 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-11-01 | 13,651 | 3,190 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 2011-12-01 | 10,046 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

---

## ✅ Conclusion

This cohort analysis using Snowflake SQL provided key insights across three dimensions:

- **Order Level:** The December 2010 cohort showed the highest transaction volume (1,701 invoices in Month_0), with a gradual decline in subsequent months across all cohorts.
- **Customer Retention:** Retention rates drop significantly after Month_0, highlighting the importance of re-engagement strategies.
- **Revenue:** The December 2010 cohort generated the highest revenue (66,676 in Month_0), with most cohorts showing declining revenue trends over time.

These insights can guide data-driven decisions for improving customer retention, engagement, and revenue growth strategies.

---


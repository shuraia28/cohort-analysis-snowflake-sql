SALES.COHORT_ANALYSIS.RETAILcreate database sales;
create schema cohort_analysis;
use schema cohort_analysis;
 Create or replace table Retail (
 InvoiceNo varchar(10),
StockCode varchar(20),
Description varchar(100),
Quantity number(8,2),
InvoiceDate varchar(25),
UnitPrice number(8,2),
CustomerID number(10),
Country varchar(25)
);
SELECT * from RETAIL limit 5;


select count (*) from retail;



--cohort analysis in SQL....


-- Step 1: Create a Common Table Expression (CTE) named CTE1 to prepare data
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

-- Step 4: Perform the final query to pivot and count invoices by cohort months
SELECT *
FROM CTE3
PIVOT (
    COUNT(InvoiceNo) FOR COHORT_MONTH IN (
        'Month_0', 'Month_1', 'Month_2', 'Month_3', 'Month_4', 'Month_5',
        'Month_6', 'Month_7', 'Month_8', 'Month_9', 'Month_10', 'Month_11', 'Month_12'
    )
)
ORDER BY FIRST_PURCHASE_MONTH;

-- Cohort Analysis/Customer Retention Analysis on Customer Level

-- Step 1: Create a Common Table Expression (CTE) named CTE1 to prepare data
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


-- Cohort Analysis on Number of Revenue

-- Creating a temporary table (CTE1) to calculate revenue from valid transactions
WITH CTE1 AS
(
    SELECT 
        CUSTOMERID,
        to_date(INVOICEDATE, 'DD/MM/YY HH24:MI') AS INVOICEDATE,
        ROUND(QUANTITY*UNITPRICE, 0) AS REVENUE
    FROM RETAIL
    WHERE CUSTOMERID IS NOT NULL
    and INVOICENO IS NOT NULL
    and quantity>0
    and unitprice>0
),

-- Creating CTE2 to calculate cohort-related metrics
CTE2 AS
(
    SELECT 
        CUSTOMERID, 
        INVOICEDATE, 
        DATE_TRUNC('MONTH', INVOICEDATE) AS PURCHASE_MONTH,
        DATE_TRUNC('MONTH', MIN(INVOICEDATE) OVER (PARTITION BY CUSTOMERID ORDER BY INVOICEDATE)) AS FIRST_PURCHASE_MONTH,
        REVENUE
    FROM CTE1
),

-- Creating CTE3 for further analysis
CTE3 AS
(
    SELECT 
        FIRST_PURCHASE_MONTH as Cohort,
        CONCAT('Month_', datediff('MONTH', FIRST_PURCHASE_MONTH, PURCHASE_MONTH)) AS COHORT_MONTH,
        REVENUE
    FROM CTE2
)

-- Generating the cohort analysis table with pivot and summing revenue for each cohort and month
SELECT *
FROM CTE3
PIVOT(
    SUM(REVENUE) 
    FOR COHORT_MONTH IN (
        'Month_0','Month_1','Month_2','Month_3','Month_4','Month_5',
        'Month_6','Month_7','Month_8','Month_9','Month_10','Month_11','Month_12'
    )
)
ORDER BY Cohort;
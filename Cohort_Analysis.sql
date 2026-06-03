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
SELECT * from RETAIL limit 10;
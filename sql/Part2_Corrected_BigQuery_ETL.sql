-- Portfolio documentation: THIS SCRIPT WAS NOT EXECUTED IN BIGQUERY.
-- Replace your-project-id with your Google Cloud project ID before any execution.
-- BI CAPSTONE / PART 2: CORRECTED BIGQUERY ETL
-- Project shown in original submitted Part 2 document: your-project-id
-- Execution status: PREPARED, NOT RUN (BigQuery access is unavailable).
-- Source tables expected in: project.raw
-- Output tables expected in: project.curated
-- IMPORTANT: The original submitted report shows raw_stores columns as
-- string_field_0, string_field_1, string_field_2, string_field_3.
-- This script explicitly maps those fields. If the table has been reloaded
-- with proper headers, replace these four names with StoreID, StoreName,
-- City, Region in the dim_stores CREATE TABLE statement.
-- The extra raw Age, Tenure and Profit columns from the previous submission
-- are intentionally ignored. Raw source data is never updated or altered.
-- SQL uses NUMERIC monetary values to avoid FLOAT64 accounting imprecision.

-- SECTION A. CURATED DATASET
CREATE SCHEMA IF NOT EXISTS `your-project-id.curated`;

-- SECTION B. QUALITY GATES: STOP IF SOURCE KEYS ARE INVALID
ASSERT (
  (SELECT COUNT(*) FROM `your-project-id.raw.raw_transactions`
   WHERE TransactionID IS NULL OR CustomerID IS NULL
      OR ProductID IS NULL OR StoreID IS NULL OR `Date` IS NULL) = 0
) AS 'Transactions must have valid keys and dates';

ASSERT (
  (SELECT COUNT(*) FROM (
    SELECT TransactionID
    FROM `your-project-id.raw.raw_transactions`
    GROUP BY TransactionID HAVING COUNT(*) > 1
  )) = 0
) AS 'TransactionID must be unique';

ASSERT (
  (SELECT COUNT(*) FROM (
    SELECT CustomerID
    FROM `your-project-id.raw.raw_customers`
    GROUP BY CustomerID HAVING COUNT(*) > 1
  )) = 0
) AS 'CustomerID must be unique';

ASSERT (
  (SELECT COUNT(*) FROM (
    SELECT ProductID
    FROM `your-project-id.raw.raw_products`
    GROUP BY ProductID HAVING COUNT(*) > 1
  )) = 0
) AS 'ProductID must be unique';

ASSERT (
  (SELECT COUNT(*) FROM (
    SELECT string_field_0
    FROM `your-project-id.raw.raw_stores`
    GROUP BY string_field_0 HAVING COUNT(*) > 1
  )) = 0
) AS 'StoreID must be unique';

ASSERT (
  (SELECT COUNT(*)
   FROM `your-project-id.raw.raw_transactions` AS t
   LEFT JOIN `your-project-id.raw.raw_customers` AS c
     ON t.CustomerID = c.CustomerID
   WHERE c.CustomerID IS NULL) = 0
) AS 'All CustomerIDs must match the customer dimension';

ASSERT (
  (SELECT COUNT(*)
   FROM `your-project-id.raw.raw_transactions` AS t
   LEFT JOIN `your-project-id.raw.raw_products` AS p
     ON t.ProductID = p.ProductID
   WHERE p.ProductID IS NULL) = 0
) AS 'All ProductIDs must match the product dimension';

ASSERT (
  (SELECT COUNT(*)
   FROM `your-project-id.raw.raw_transactions` AS t
   LEFT JOIN `your-project-id.raw.raw_stores` AS s
     ON t.StoreID = s.string_field_0
   WHERE s.string_field_0 IS NULL) = 0
) AS 'All StoreIDs must match the store dimension';

ASSERT (
  (SELECT COUNT(*) FROM `your-project-id.raw.raw_transactions`
   WHERE SAFE_CAST(Quantity AS INT64) IS NULL
      OR SAFE_CAST(Quantity AS INT64) <= 0
      OR SAFE_CAST(Discount AS NUMERIC) IS NULL
      OR SAFE_CAST(Discount AS NUMERIC) < 0
      OR SAFE_CAST(Discount AS NUMERIC) > 1
      OR SAFE_CAST(`Date` AS DATE) IS NULL) = 0
) AS 'Transaction quantity, discount and date must be valid';

ASSERT (
  (SELECT COUNT(*) FROM `your-project-id.raw.raw_products`
   WHERE SAFE_CAST(UnitPrice AS NUMERIC) IS NULL
      OR SAFE_CAST(CostPrice AS NUMERIC) IS NULL
      OR SAFE_CAST(UnitPrice AS NUMERIC) < 0
      OR SAFE_CAST(CostPrice AS NUMERIC) < 0) = 0
) AS 'Product price and cost must be valid';

-- SECTION C. CUSTOMER DIMENSION
-- Tenure here is time since JoinDate, not first-purchase tenure.
-- BigQuery recalculates Age / Tenure using CURRENT_DATE() upon ETL rerun.
CREATE OR REPLACE TABLE `your-project-id.curated.dim_customers` AS
WITH typed AS (
  SELECT
    TRIM(CAST(CustomerID AS STRING)) AS CustomerID,
    CAST(FirstName AS STRING) AS FirstName,
    CAST(LastName AS STRING) AS LastName,
    CAST(Gender AS STRING) AS Gender,
    CAST(City AS STRING) AS City,
    SAFE_CAST(BirthDate AS DATE) AS BirthDate,
    SAFE_CAST(JoinDate AS DATE) AS JoinDate
  FROM `your-project-id.raw.raw_customers`
), calculated AS (
  SELECT *,
    DATE_DIFF(CURRENT_DATE(), BirthDate, YEAR)
      - IF(FORMAT_DATE('%m%d', CURRENT_DATE())
        < FORMAT_DATE('%m%d', BirthDate), 1, 0) AS Age,
    DATE_DIFF(CURRENT_DATE(), JoinDate, YEAR)
      - IF(FORMAT_DATE('%m%d', CURRENT_DATE())
        < FORMAT_DATE('%m%d', JoinDate), 1, 0) AS Tenure
  FROM typed
)
SELECT *,
  CASE
    WHEN Age < 25 THEN 'Under 25'
    WHEN Age < 35 THEN '25-34'
    WHEN Age < 45 THEN '35-44'
    WHEN Age < 55 THEN '45-54'
    WHEN Age < 65 THEN '55-64'
    ELSE '65+'
  END AS AgeGroup,
  CASE
    WHEN Tenure < 1 THEN 'Under 1 year'
    WHEN Tenure < 3 THEN '1-2 years'
    WHEN Tenure < 5 THEN '3-4 years'
    ELSE '5+ years'
  END AS TenureGroup
FROM calculated;

-- SECTION D. PRODUCT DIMENSION
CREATE OR REPLACE TABLE `your-project-id.curated.dim_products` AS
SELECT
  TRIM(CAST(ProductID AS STRING)) AS ProductID,
  CAST(ProductName AS STRING) AS ProductName,
  CAST(Category AS STRING) AS Category,
  CAST(SubCategory AS STRING) AS SubCategory,
  SAFE_CAST(UnitPrice AS NUMERIC) AS UnitPrice,
  SAFE_CAST(CostPrice AS NUMERIC) AS CostPrice,
  SAFE_CAST(UnitPrice AS NUMERIC)
    - SAFE_CAST(CostPrice AS NUMERIC) AS ProfitPerUnit
FROM `your-project-id.raw.raw_products`;

-- SECTION E. STORE DIMENSION
-- Columns below match the naming shown in the user's Part 2 report.
CREATE OR REPLACE TABLE `your-project-id.curated.dim_stores` AS
SELECT
  TRIM(CAST(string_field_0 AS STRING)) AS StoreID,
  CAST(string_field_1 AS STRING) AS StoreName,
  CAST(string_field_2 AS STRING) AS City,
  CAST(string_field_3 AS STRING) AS Region
FROM `your-project-id.raw.raw_stores`
WHERE TRIM(CAST(string_field_0 AS STRING)) != 'StoreID'
  AND string_field_0 IS NOT NULL;

-- SECTION F. FACT TABLE: ONE ROW PER TRANSACTION
-- Assignment Profit: (UnitPrice - CostPrice) * Quantity (pre-discount).
-- NetProfit: TotalSales - (CostPrice * Quantity) (post-discount).
CREATE OR REPLACE TABLE `your-project-id.curated.fact_sales` AS
WITH typed AS (
  SELECT
    TRIM(CAST(t.TransactionID AS STRING)) AS TransactionID,
    SAFE_CAST(t.`Date` AS DATE) AS `Date`,
    TRIM(CAST(t.CustomerID AS STRING)) AS CustomerID,
    TRIM(CAST(t.ProductID AS STRING)) AS ProductID,
    TRIM(CAST(t.StoreID AS STRING)) AS StoreID,
    SAFE_CAST(t.Quantity AS INT64) AS Quantity,
    SAFE_CAST(t.Discount AS NUMERIC) AS Discount,
    CAST(t.PaymentMethod AS STRING) AS PaymentMethod,
    p.UnitPrice,
    p.CostPrice
  FROM `your-project-id.raw.raw_transactions` AS t
  INNER JOIN `your-project-id.curated.dim_products` AS p
    ON TRIM(CAST(t.ProductID AS STRING)) = p.ProductID
  INNER JOIN `your-project-id.curated.dim_customers` AS c
    ON TRIM(CAST(t.CustomerID AS STRING)) = c.CustomerID
  INNER JOIN `your-project-id.curated.dim_stores` AS s
    ON TRIM(CAST(t.StoreID AS STRING)) = s.StoreID
)
SELECT *,
  Quantity * UnitPrice AS GrossSales,
  Quantity * UnitPrice * Discount AS DiscountAmount,
  Quantity * UnitPrice * (1 - Discount) AS TotalSales,
  (UnitPrice - CostPrice) * Quantity AS Profit,
  (UnitPrice * (1 - Discount) - CostPrice)
    * Quantity AS NetProfit
FROM typed;

-- SECTION G. DATE DIMENSION
CREATE OR REPLACE TABLE `your-project-id.curated.dim_date` AS
SELECT DISTINCT
  `Date` AS FullDate,
  EXTRACT(YEAR FROM `Date`) AS Year,
  EXTRACT(MONTH FROM `Date`) AS MonthNumber,
  FORMAT_DATE('%B', `Date`) AS MonthName,
  EXTRACT(QUARTER FROM `Date`) AS Quarter,
  EXTRACT(DAYOFWEEK FROM `Date`) AS DayOfWeek,
  FORMAT_DATE('%A', `Date`) AS DayName,
  DATE_TRUNC(`Date`, MONTH) AS MonthStart
FROM `your-project-id.curated.fact_sales`
WHERE `Date` IS NOT NULL;

-- SECTION H. FINAL CHECKS
-- Expected row counts from the supplied Excel. Fail rather than silently
-- accept extra header records or incomplete dimensions.
ASSERT (
  (SELECT COUNT(*) FROM `your-project-id.curated.dim_customers`) = 200
  AND (SELECT COUNT(*) FROM `your-project-id.curated.dim_products`) = 50
  AND (SELECT COUNT(*) FROM `your-project-id.curated.dim_stores`) = 5
) AS 'Dimension counts must match supplied workbook';

ASSERT (
  (SELECT COUNT(*) FROM `your-project-id.curated.fact_sales`)
   = (SELECT COUNT(*) FROM `your-project-id.raw.raw_transactions`)
) AS 'Fact row count must equal raw transaction row count';

ASSERT (
  (SELECT COUNT(DISTINCT TransactionID)
   FROM `your-project-id.curated.fact_sales`)
   = (SELECT COUNT(*) FROM `your-project-id.raw.raw_transactions`)
) AS 'Each fact row must have a unique TransactionID';

-- Returns validation totals for comparison with the original workbook.
SELECT
  COUNT(*) AS TransactionCount,
  COUNT(DISTINCT TransactionID) AS UniqueTransactionIDs,
  COUNT(DISTINCT CustomerID) AS CustomersWithTransactions,
  COUNT(DISTINCT ProductID) AS ProductsWithTransactions,
  COUNT(DISTINCT StoreID) AS StoresWithTransactions,
  ROUND(SUM(GrossSales), 2) AS GrossSales,
  ROUND(SUM(DiscountAmount), 2) AS TotalDiscountAmount,
  ROUND(SUM(TotalSales), 2) AS TotalRevenue,
  ROUND(SUM(Profit), 2) AS ProfitBeforeDiscount,
  ROUND(SUM(NetProfit), 2) AS NetProfitAfterDiscount,
  ROUND(SAFE_DIVIDE(SUM(NetProfit), SUM(TotalSales)), 4)
    AS NetProfitMargin
FROM `your-project-id.curated.fact_sales`;

-- SECTION I. OPTIONAL TABLEAU VIEW (ONE ROW PER TRANSACTION)
CREATE OR REPLACE VIEW `your-project-id.curated.v_tableau_sales` AS
SELECT
  f.*,
  p.ProductName,
  p.Category,
  p.SubCategory,
  p.ProfitPerUnit,
  s.StoreName,
  s.City AS StoreCity,
  s.Region,
  c.FirstName,
  c.LastName,
  c.Gender,
  c.City AS CustomerCity,
  c.BirthDate,
  c.JoinDate,
  c.Age,
  c.Tenure,
  c.AgeGroup,
  c.TenureGroup,
  d.Year,
  d.MonthNumber,
  d.MonthName,
  d.Quarter,
  d.DayOfWeek,
  d.DayName,
  d.MonthStart
FROM `your-project-id.curated.fact_sales` AS f
INNER JOIN `your-project-id.curated.dim_products` AS p
  ON f.ProductID = p.ProductID
INNER JOIN `your-project-id.curated.dim_stores` AS s
  ON f.StoreID = s.StoreID
INNER JOIN `your-project-id.curated.dim_customers` AS c
  ON f.CustomerID = c.CustomerID
INNER JOIN `your-project-id.curated.dim_date` AS d
  ON f.`Date` = d.FullDate;

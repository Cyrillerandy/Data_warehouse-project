/*
=========================================================================
Quality Checks Script
=========================================================================
Purpose:
  To perform quality checks on the data after loading into the silver 
  schema, covering aspects like data accuracy, consistency and 
  standardization.

  It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in text data columns.
  - Data standardization/normalization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields

Any discrepancies found should be investigated and resolved.
=========================================================================
*/

-- =========================================================================
-- Checking silver.crm_cust_info table
-- =========================================================================
-- Check for nulls and duplicates in the primary key
-- Expected result: No nulls or duplicates
SELECT
	cst_id,
	COUNT(*)
FROM 
	silver.crm_cust_info
GROUP BY
	cst_id
HAVING
	COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted/trailing spaces in the text columns
-- Switch the column names between the relevant text columns
-- Expected result: No trailing spaces
SELECT 
	cst_firstname
FROM
	silver.crm_cust_info
WHERE
	cst_lastname != TRIM(cst_lastname);

-- Data standardization and consistency
-- Switch the column names between the relevant columns
-- Expected result: Values within expected range
SELECT
	DISTINCT cst_marital_status -- or cst_gndr
FROM
	silver.crm_cust_info;

-- =========================================================================
-- Checking silver.crm_prd_info table
-- =========================================================================
-- Check for nulls and duplicates in the primary key
-- Expected result: No nulls or duplicates
SELECT
	prd_id,
	COUNT(*)
FROM
	silver.crm_prd_info
GROUP BY
	prd_id
HAVING
	COUNT(*) > 1 OR prd_id IS NULL;

-- We will need to join some tables together
-- The prd_key is split into two in the erp_px_cat_g1v2 and crm_sales_details tables
-- Expected result: No errors in the key columns
SELECT * FROM bronze.crm_prd_info; -- contains the full prd_key
SELECT * FROM bronze.erp_px_cat_g1v2; -- contains first five characters of prd_key with an underscore
SELECT * FROM bronze.crm_sales_details; -- contains the rest of the characters of prd_key

-- Fix from the bronze tables
SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Derived column for category id
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Derived column for product key
	prd_name,
	prd_cost, 
  prd_line, 
	prd_start_dt, 
	prd_end_dt 
FROM 
	bronze.crm_prd_info;

--Confirm/check in silver schema
SELECT * FROM silver.crm_prd_info;

-- Check for trailing spaces in the product name
-- Expected result: No trailing spaces
SELECT
	*
FROM
	silver.crm_prd_info
WHERE
	prd_name != TRIM(prd_name);

-- Check for Null or Negative product costs
-- Expected result: No nulls or negatives
SELECT
	*
FROM
	silver.crm_prd_info
WHERE
	prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization check
-- Expected result: No data inconsistency
SELECT
	DISTINCT prd_line
FROM
	silver.crm_prd_info;

-- Date quality check
-- We still have nulls which is expected
-- Expected result: No unexpected invalid date data
SELECT
	*
FROM
	silver.crm_prd_info
WHERE
	prd_start_dt > prd_end_dt OR prd_end_dt IS NULL;

-- =========================================================================
-- Checking silver.crm_sales_details table
-- =========================================================================
-- Check if sls_ord_num(order number for sales) has trailing spaces
-- Expected result: No trailing spaces
SELECT
	sls_ord_num
FROM
	silver.crm_sales_details
WHERE
	sls_ord_num <> TRIM(sls_ord_num);

-- Check that our composite primary key has no duplicates
-- Expected result: No duplicates
SELECT
	sls_ord_num,
	sls_prd_key,
	COUNT(*)
FROM
	silver.crm_sales_details
GROUP BY sls_ord_num, sls_prd_key
HAVING COUNT(*) > 1;

-- Check quality of prd_key and cust_id
-- Will be needed for joins, confirm presence in tables
-- Expected result: No errors
SELECT
	*
FROM
	silver.crm_sales_details
WHERE
	sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- Check for date quality
-- 0, nulls or invalid lengths
-- Expected result: No invalid date data
SELECT
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM
	silver.crm_sales_details
WHERE
	sls_due_dt = 0
	OR LEN(sls_due_dt) != 8 -- Length of the dates presented as integers is 8
	OR sls_due_dt > 20500101 -- Maximum date we want (can change based on business rules)
	OR sls_due_dt < 19000101 -- Minimum date we want (can change based on business rules);

-- Check for quality of the order dates
-- Expected result: Order dates lower than due and ship dates
SELECT 
	*
FROM
	bronze.crm_sales_details
WHERE
	sls_order_dt > sls_due_dt; -- can substitute due date with ship date

-- Check data consistency
-- Sales = quantity * price (check if this rule holds true)
-- The data cannot be null, negative or zero as well.
-- Expected result: No nulls, zero or negative values
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM
	silver.crm_sales_details
WHERE
	sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * sls_price OR
	sls_quantity IS NULL OR sls_quantity <= 0 OR
	sls_price IS NULL OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- =========================================================================
-- Checking silver.erp_cust_az12 table
-- =========================================================================
-- Check for inconsistencies in the primary key
-- Expected result: No inconsistencies
SELECT 
  cid 
FROM 
  silver.erp_cust_az12 
WHERE 
  cid LIKE 'NAS%';

-- Check for invalidity in the dates
-- Less than or above a certain threshold (let's go 100 years back and anyone born after today)
-- Not sure about the lower dates but the higher dates are clear errors, we remove those for now
-- Expected result: No invalid date data
SELECT
	bdate
FROM
	silver.erp_cust_az12
WHERE
	bdate < '1924-01-01' OR bdate > GETDATE();

-- Check for data consistency in the gender column
-- Expected result: Data is consistent
SELECT DISTINCT
	gen
FROM
	silver.erp_cust_az12;

-- =========================================================================
-- Checking silver.erp_loc_a101 table
-- =========================================================================
-- Check primary key compatibility with key in other relevant table(s)
-- Expected result: No errors
SELECT cst_key FROM silver.crm_cust_info;

SELECT
	*
FROM
	silver.erp_loc_a101
WHERE
	cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

-- Check for data consistency in the country column
-- Expected result: Data is consistent
SELECT DISTINCT
	cntry
FROM
	silver.erp_loc_a101
ORDER BY 
	cntry;

-- =========================================================================
-- Checking silver.erp_loc_a101 table
-- =========================================================================
-- Check primary key against relevant join tables
-- Expected result: No errors
SELECT DISTINCT cat_id FROM silver.crm_prd_info;
SELECT DISTINCT id FROM silver.erp_px_cat_g1v2;

-- Check for unwanted spaces in the text columns
-- Expected result: No trailing spaces
SELECT
	*
FROM
	silver.erp_px_cat_g1v2
WHERE
	cat != TRIM(cat) OR 
	subcat != TRIM(subcat) OR 
	maintenance != TRIM(maintenance);

-- Check data consistency and standardization (cat, subcat, maintenance columns)
-- Expexted result: No issues spotted
SELECT
	DISTINCT maintenance -- change columns between cat, subcat and maintenance
FROM
	bronze.erp_px_cat_g1v2;





















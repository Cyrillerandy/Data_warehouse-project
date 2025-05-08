/*
===========================================================================
Quality checks
===========================================================================
Purpose:
  This script performs validation checks to ensure integrity, 
  consistency and accuracy of the data in the Gold Layer.

  The checks are meant to enforce/ensure:
  - The surrogate keys in the dimension tables are unique
  - There is Referential Integrity between the fact and 
    dimension tables
  - Validation of the data model's relationshios for 
    analytics purposes.

NB:
  * The checks should be run after loading data into the Silver Layer.
  * Any discrepancies found during the checks should be investigated
    and propmptly resolved.
*/


/*
===========================================================================
Checking "gold.dim_customers"
===========================================================================
Checks:
  1  Check for null values in the customer_key
     Expected outcome: No nulls expected
  2  Check for validity of data in our integrated column (gender column)
     Expected outcome: No invalid data
*/

-- 1.
SELECT
	customer_key,
	COUNT(*)
FROM
	gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- 2. 
SELECT DISTINCT 
  gender 
FROM 
  gold.dim_customers;


/*
===========================================================================
Checking "gold.dim_products"
===========================================================================
Checks:
  1 Check for null values in the product_key
    Expected outcome: No nulls expected
*/

-- 1.
SELECT
	product_key,
	COUNT(*)
FROM
	gold.dim_products
GROUP BY
	product_key
HAVING
	COUNT(*) > 1;

/*
===========================================================================
Checking "gold.fact_sales"
===========================================================================
Checks:
  1 Check for referential integrity of joins with other tables and 
    nulls in the foreign keys
    Expected outcome: No nulls expected, Joins occur seamlessly
*/
SELECT
	*
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_customers AS dc
ON 
	fs.customer_key = dc.customer_key
LEFT JOIN 
	gold.dim_products AS dp
ON
	fs.product_key = dp.product_key
WHERE
	dp.product_key IS NULL; -- Use product_key or customer_key for check










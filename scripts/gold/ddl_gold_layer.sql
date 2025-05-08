/*
==========================================================================
DDL Script: Create Gold Views
==========================================================================
Purpose: 
  This script is used for the creation of views in the Gold Layer.
  The Gold layer is the final/business-end layer of the database.

  It's designed as a star schema data model.
  It holds two dimension tables and one fact table.

  Each of the created views performs data transformation where needed
  and combines data from the silver layer tabels to create clean, data
  enriched and business-ready datatset for analytics and reporting.
==========================================================================
*/

-- Create customers dimension view
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name, 
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE	
		WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'N/A')
	END AS gender,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM
	silver.crm_cust_info AS ci
LEFT JOIN 
	silver.erp_cust_az12 AS ca
ON
	ci.cst_key = ca.cid
LEFT JOIN
	silver.erp_loc_a101 AS la
ON
	ci.cst_key = la.cid;
GO

-- Create products dimension view
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY pd.prd_start_dt, pd.prd_key) AS product_key,
	pd.prd_id AS product_id,
	pd.prd_key AS product_number,
	pd.prd_name AS product_name,
	pd.cat_id AS category_id,
	pcg.cat AS category,
	pcg.subcat AS subcategory,
	pcg.maintenance,
	pd.prd_cost AS product_cost,
	pd.prd_line AS product_line,
	pd.prd_start_dt AS product_startdate
FROM
	silver.crm_prd_info AS pd
LEFT JOIN
	silver.erp_px_cat_g1v2 AS pcg
ON
	pd.cat_id = pcg.id
WHERE
	pd.prd_end_dt IS NULL;
GO

-- Create fact sales view
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS order_number,
	dp.product_key,
	dc.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM
	silver.crm_sales_details AS sd
LEFT JOIN
	gold.dim_customers AS dc
ON
	sd.sls_cust_id = dc.customer_id
LEFT JOIN
	gold.dim_products AS dp
ON
	sd.sls_prd_key = dp.product_number;
GO

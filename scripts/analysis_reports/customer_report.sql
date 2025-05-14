/*
================================================================================
	Customer Report
================================================================================

Purpose:
	The purpose of this report is to integrate the key customer metrics and 
	behaviours seen in our data and add the final report into the business/gold 
  schema as a view for easy analysis by the end user.

Aspects Covered:
	- Gathers essential field names such as names, ages and transaction 
	  details.
	- Segments the customers into different categories such as age groups 
	  and spending categories based on the time they've been customers of 
	  the business (VIP, New, Regular).
	- Aggregates customer level metrics. These include:
	  ~ total orders
	  ~ total sales
	  ~ total quantity purchased
	  ~ total products
	  ~ lifespan (in months)
	- Calculates Valuable KPIs. These include:
	  ~ recency (number of months since last order)
	  ~ average order value
	  ~ average monthly spend
================================================================================
*/

IF OBJECT_ID('gold.customer_report', 'V') IS NOT NULL
	DROP VIEW gold.customer_report;
GO

CREATE VIEW gold.customer_report AS
WITH customer_details AS (
-- 1. Base Query
-- Retrieve core columns from tables
SELECT
	fs.order_number,
	fs.product_key,
	fs.order_date,
	fs.sales_amount,
	fs.quantity,
	dc.customer_key,
	dc.customer_number,
	CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name, -- get the full name
	DATEDIFF(YEAR, dc.birth_date, GETDATE()) AS age -- calculate the age
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_customers AS dc
ON
	fs.customer_key = dc.customer_key
WHERE
	fs.order_date IS NOT NULL),
customer_aggregation AS (
-- 2. Customer metric aggregations
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT product_key) AS total_products,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity_bought,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM 
	customer_details
GROUP BY
	customer_key, customer_number, customer_name, age)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE	
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN AGE BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and Over'
	END AS age_group, 
	total_orders,
	total_sales,
	CASE	
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_value, -- calculate the average order value
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_spend, -- calculate the average monthly spend
	total_products,
	total_quantity_bought,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency, -- calculate the time that has passed since the last order
	lifespan,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_category -- segment the customers
FROM
	customer_aggregation;
GO

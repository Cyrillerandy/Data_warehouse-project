/*
===========================================================================
	Product report
===========================================================================

Purpose:
	The purpose of this report is to integrate key product metrics and add
  the final report as a view to the business/gold schema for easy analysis
  by the end-user.

Aspects Covered:
	- Gathers essential fields like product name, category, subcategory
	  and cost.
	- Segments products by revenue to identify High, Mid-Range or Low 
	  performers.
	- Aggregates product level metrics including:
	  ~ total orders
	  ~ total sales
	  ~ total quantity sold
	  ~ total unique customers
	  ~ lifespan(in months)
	- Calcualte valuable KPIs including:
	  ~ recency (months since last sale)
	  ~ average order revenue
	  ~ average monthly revenue
===========================================================================
*/

IF OBJECT_ID('gold.product_report', 'V') IS NOT NULL
	DROP VIEW gold.product_report;
GO

CREATE VIEW gold.product_report AS
WITH product_details AS (
-- 1. Base query to get the necessary data
SELECT
	fs.order_number,
	fs.customer_key,
	fs.order_date,
	fs.sales_amount,
	fs.quantity,
	dp.product_key,
	dp.product_number,
	dp.product_name,
	dp.category,
	dp.subcategory,
	dp.product_cost,
	dp.product_line
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_products AS dp
ON
	fs.product_key = dp.product_key
WHERE
	fs.order_date IS NOT NULL),
product_aggregation AS (
-- 2. Product metrics aggregation
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity_sold,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price,
	COUNT(DISTINCT customer_key) AS num_customers,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM
	product_details
GROUP BY
	product_key, product_name, category, subcategory, product_cost)
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	total_orders,
	total_sales,
	avg_selling_price,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue, -- compute the average revenue by orders
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue, -- compute the average revenue generated per month
	CASE	
		WHEN total_sales < 10000 THEN 'Low'
		WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-range'
		ELSE 'High'
	END AS performance_category, -- product segmentation
	total_quantity_sold,
	num_customers,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency, -- compute the months elapsed since the last order
	lifespan
FROM
	product_aggregation;
GO

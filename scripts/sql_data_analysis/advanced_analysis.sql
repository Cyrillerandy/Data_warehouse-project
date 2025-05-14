/*
===================================================================================================
  Advanced SQL Analysis
===================================================================================================

In this script we will do some more advanced analytics with sql in an attempt to answer business 
questions.

We will utilise more complex queries, window functions, CTEs and subqueries just to name a few
tools at our disposal, to do our analysis.

Some of the analyses we will do include:
- Change over time analysis
- Cumulative analysis
- Performance analysis
- Part-to-whole analysis
- Data Segementation

NB: The analysis in this script is not exhaustive. The script is subject to change.
===================================================================================================
*/

/*
1. Change Over Time 

This involves the analysis of how a measure changes/evolves over a period of time
Useful for trend tracking and identifying seasonality patterns in the data
*/

-- Let's use the gold.fact_sales table
SELECT * FROM gold.fact_sales;

-- Changes in sales, quantity sold and number of customers over time
SELECT
	YEAR(order_date) AS order_year, -- play around with the granularity (year/month/day)
	MONTH(order_date) AS order_month, -- play around with the granularity (year/month/day)
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT(customer_key)) AS num_customers,
	SUM(quantity) AS total_quantity_sold
FROM
	gold.fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	YEAR(order_date), MONTH(order_date)
ORDER BY
	YEAR(order_date), MONTH(order_date);

-- Datetrunc function
SELECT
	DATETRUNC(MONTH, order_date) AS order_date, -- play around with the date's granularity
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT(customer_key)) AS num_customers,
	SUM(quantity) AS total_quantity_sold
FROM
	gold.fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	DATETRUNC(MONTH, order_date)
ORDER BY
	DATETRUNC(MONTH, order_date);

-- Format function
SELECT
	FORMAT(order_date, 'yyyy-MMM') AS order_date, -- play around with the date's granularity
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT(customer_key)) AS num_customers,
	SUM(quantity) AS total_quantity_sold
FROM
	gold.fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	FORMAT(order_date, 'yyyy-MMM')
ORDER BY
	FORMAT(order_date, 'yyyy-MMM');

-- Customers added over time
SELECT
	DATETRUNC(YEAR, create_date) AS create_date, -- Play around with the date granularity
	COUNT(DISTINCT customer_key) AS num_customers
FROM
	gold.dim_customers
WHERE
	create_date IS NOT NULL
GROUP BY
	DATETRUNC(YEAR, create_date)
ORDER BY
	DATETRUNC(YEAR, create_date);


/*
2. Cumulative analysis 

This involves aggregating our data over time
Useful for understanding growth/decline rates of business processes, etc.
*/

-- Calculate the total sales per month and the running total of sales over time
SELECT
	*,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM(
SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM
	gold.fact_sales
WHERE
	order_date IS  NOT NULL
GROUP BY
	DATETRUNC(MONTH, order_date)) AS t;

-- Running total and average per year/month/day
SELECT
	*,
	SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS moving_average_price
FROM(
SELECT
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM
	gold.fact_sales
WHERE
	order_date IS  NOT NULL
GROUP BY
	DATETRUNC(MONTH, order_date)) AS t;


/*
3. Performance analysis 

This involves comparing the current value of the metric being
measured with a target value
Acts as a measure of success and performance comparisons
*/

-- Analyze the yearly performance of products by comparing each product's 
-- sales to:
-- (i) Average sales
-- (ii) Previous year sales

-- Window Function
SELECT
	*,
	AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales,
	total_sales - AVG(total_sales) OVER (PARTITION BY product_name) AS diff_from_avg,
	CASE 
		WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END AS change_from_avg,
	LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
	total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_from_prev_yr,
	CASE	
		WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS change_from_prev_yr
FROM(
	SELECT
		DATETRUNC(YEAR, fs.order_date) AS order_year,
		dp.product_name,
		SUM(fs.sales_amount) AS total_sales
	FROM
		gold.fact_sales AS fs
	LEFT JOIN
		gold.dim_products AS dp
	ON
		fs.product_key = dp.product_key
	WHERE
		fs.order_date IS NOT NULL
	GROUP BY
		DATETRUNC(YEAR, fs.order_date), dp.product_name) AS t;

-- CTE
WITH yearly_sales AS (
SELECT
	YEAR(fs.order_date) AS order_year,
	dp.product_name,
	SUM(fs.sales_amount) AS current_sales
FROM
	gold.fact_sales AS fs
LEFT JOIN	
	gold.dim_products AS dp
ON
	fs.product_key = dp.product_key
GROUP BY
	dp.product_name, YEAR(fs.order_date)
)
SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_with_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Average'
	END AS change_from_avg,
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_from_prev_yr,
	CASE 
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS change_from_prev_yr
FROM
	yearly_sales
ORDER BY
	product_name, order_year;

-- This is called a year-over-year analysis for spotting long term trends
-- The date granularity can be changed e.g. to month for finer details

/*
4. Part-To-Whole/Proportional analysis 

This involves the analysis of how an individual part of a given business metric performs compared to the overall metric in question.
This allows us to gain an understanding of which of the categories under study has the greatest impact on the business.
*/

-- Which categories contribute the most to overall sales
WITH category_sales AS (
SELECT
	dp.category,
	SUM(fs.sales_amount) AS total_sales
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_products AS dp
ON
	fs.product_key = dp.product_key
GROUP BY
	dp.category)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ()) * 100, 2), '%') AS proportion
FROM
	category_sales
ORDER BY
	total_sales DESC;


/*
5. Data Segmentation

This involves grouping the data based on a specific range
This helps in understanding correlation between two measures
*/

-- Segment the products into cost ranges and count how many products
-- fall into each segment
WITH product_cost_segments AS (
SELECT
	product_key,
	product_name,
	product_cost,
	CASE	
		WHEN product_cost < 100 THEN 'Below 100'
		WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000' 
		ELSE 'Above 1000'
	END AS cost_category
FROM
	gold.dim_products)
SELECT
	cost_category,
	COUNT(DISTINCT product_name) AS num_products
FROM
	product_cost_segments
GROUP BY
	cost_category
ORDER BY num_products DESC;


-- Group customers into 3 groups based on their spending behaviour
-- - VIP: Customers with at least 12 months of history and and spending more than $5,000.
-- - Regular: Customers with at least 12 months of history but spending $5,000 or less.
-- - New: Customers with a lifespan of less than 12 months.
-- Then find the total number of customers in each group
WITH customer_spend AS (
SELECT
	fs.customer_key,
	CONCAT(dc.first_name, ' ', dc.last_name) AS full_name,
	MIN(fs.order_date) AS first_order,
	MAX(fs.order_date) AS last_order,
	SUM(fs.sales_amount) AS spend
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_customers AS dc
ON
	fs.customer_key = dc.customer_key
GROUP BY
	fs.customer_key, CONCAT(dc.first_name, ' ', dc.last_name))
SELECT
	customer_category,
	COUNT(DISTINCT customer_key) AS num_customers
FROM (
SELECT
	customer_key,
	full_name,
	CASE	
		WHEN DATEDIFF(MONTH, first_order, last_order) >= 12 AND spend > 5000 THEN 'VIP'
		WHEN DATEDIFF(MONTH, first_order, last_order) >= 12 AND spend <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_category
FROM
	customer_spend) AS t
GROUP BY
	customer_category
ORDER BY
	num_customers DESC;

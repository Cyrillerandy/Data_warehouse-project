/*
==========================================================================================================================
  Exploratory Data Analysis (EDA)
==========================================================================================================================
Exploratory data analysis involves inspecting the data in order to gain an understanding of our data and 
the insights or patterns hidden within.

In EDA we utilize basic sql queries, simple aggregations, subqueries and data profiles among other tools 
and techniques to make sense of our data.

Some of the EDA aspects covered in this script include:
  - Database Exploration
  - Dimensions Exploration
  - Date Exploration
  - Measures Exploration
  - Magnitude Analysis
  - Ranking Analysis

NB: The analysis done in this script is not exhausive, the script is subject to change. 
==========================================================================================================================
*/

/*
1. Database Exploration:
   We explore the various objects contained in our database
*/
-- Explore all objects
SELECT
	*
FROM
	INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the database
-- Mainly used to look up a specific table
SELECT
	*
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'dim_customers';


/*
2. Dimensions Exploration:
   Here, we explore the dimensions present in our database objects to identify
   the unique objects present. This will help us recognize any viable groupings
   or segments in our database, which will be useful later for analysis.

   We will focus on the gold schema as it contains the final business-ready version
   of our data
*/

--=======================================================
-- gold.dim_customers
--=======================================================
SELECT * FROM gold.dim_customers;

-- Let's dive into the customers country of residence
-- You can also look at marital status and gender as groupings for analysis
SELECT DISTINCT country FROM gold.dim_customers; -- we have 6 recorded countries

SELECT DISTINCT marital_status FROM gold.dim_customers; -- 2 groups

SELECT DISTINCT gender FROM gold.dim_customers; -- 2 groups recorded, some missing data
	
--=======================================================
-- gold.dim_products
--=======================================================
SELECT * FROM gold.dim_products;

-- We'll have a look at the groupings by unique category and subcategory, then by all products. 
-- We might also have a look at the product line values.
SELECT DISTINCT	
	category, -- We have 4 categories
	subcategory, -- We have 36 subcategories
	product_name -- We have 295 products, 7 products have no assigned category or subcategory
FROM
	gold.dim_products;

-- product line
SELECT DISTINCT product_line FROM gold.dim_products; -- We have 4 distinct product lines

-- Our fact sales table has no dimensions, we leave it out for this one
SELECT * FROM gold.fact_sales;


/*
3. Date Exploration
   Here we want to find the date boundaries (earliest and latest dates)
   This helps us undestand the scope and timespan of our data
*/

-- ============================================================
-- gold.fact_sales
-- ============================================================
SELECT * FROM gold.fact_sales; -- We have 3 date columns; order, shipping and due date columns

-- Find the date of the first and the last order
-- By looking at that we will have an idea of the duration for the sales data available
-- We can also calculate that as well
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS "Order Range (Years)",
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS "Order Range (Months)"
FROM
	gold.fact_sales;

-- We can do the same for shipping and due dates, just change the columns in the query

-- ============================================================
-- gold.dim_customers
-- ============================================================
SELECT * FROM gold.dim_customers;

-- Let's look at the birthdate, let's find the oldest and the youngest customers
SELECT
	*,
	DATEDIFF(YEAR, birth_date, GETDATE()) AS customer_age
FROM
	gold.dim_customers
WHERE
	birth_date IN (SELECT MIN(birth_date) FROM gold.dim_customers) OR
	birth_date IN (SELECT MAX(birth_date) FROM gold.dim_customers);


/*
4. Measures Exploration
   Here we calculate the key business metrics
   We find the highest level of aggregation/lowest level of detail
*/

-- Find the total sales
SELECT
	SUM(sales_amount) AS total_sales
FROM 
	gold.fact_sales;

-- Find how many items were sold
SELECT
	SUM(quantity) AS total_quantity_sold
FROM
	gold.fact_sales;

-- Find the average selling price
SELECT
	AVG(price) AS average_price
FROM
	gold.fact_sales;

-- Find the total number of orders
SELECT
	COUNT(DISTINCT order_number) AS total_orders
FROM
	gold.fact_sales;

-- Find the total number of products
SELECT
	COUNT(DISTINCT product_name) AS num_products
FROM
	gold.dim_products;

-- Find the Find the total number of customers
SELECT
	COUNT(DISTINCT customer_id) AS num_customers
FROM
	gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT
	COUNT(DISTINCT customer_key) AS num_customers_with_orders
FROM
	gold.fact_sales;

-- Now we generate a report that shows all the metrics in one table
-- Can use UNION
SELECT 'Total Sales' AS "Measure Name", SUM(sales_amount) AS "Measure Value" FROM gold.fact_sales
UNION 
SELECT 'Total Quantity Sold',SUM(quantity) FROM gold.fact_sales
UNION
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION
SELECT 'Total Number of Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION
SELECT 'Total Number of Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION
SELECT 'Total Number of Customers', COUNT(DISTINCT customer_key) FROM gold.dim_customers
UNION
SELECT 'Total Number of Customer with Orders', COUNT(DISTINCT customer_key) FROM gold.fact_sales;

-- Or UNION ALL
SELECT 'Total Sales' AS "Measure Name", SUM(sales_amount) AS "Measure Value" FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity Sold',SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Number of Customers', COUNT(DISTINCT customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Total Number of Customer with Orders', COUNT(DISTINCT customer_key) FROM gold.fact_sales;


/*
4. Magnitude Analysis
   Here we compare our measures against different categories
   This helps us understand the importance of the different categegories
*/

-- Find total customers by countries
SELECT country, COUNT(DISTINCT customer_key) AS num_customers FROM gold.dim_customers
GROUP BY country
ORDER BY num_customers DESC;

-- Find total customers by gender
SELECT gender, COUNT(customer_key) AS num_customers FROM gold.dim_customers
GROUP BY gender
ORDER BY num_customers DESC;

-- Find total products by category
SELECT category, COUNT(DISTINCT product_name) AS num_products FROM gold.dim_products
GROUP BY category
ORDER BY num_products DESC;

-- What is the average cost in each category?
SELECT category, AVG(product_cost) AS avg_cost FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?
SELECT dp.category, SUM(fs.sales_amount) AS revenue FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
ON dp.product_key = fs.product_key
GROUP BY dp.category
ORDER BY revenue DESC;

-- Find the total revenue generated by each customer
SELECT dc.customer_key, dc.first_name, dc.last_name, SUM(sales_amount) AS revenue FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.customer_key, dc.first_name, dc.last_name
ORDER BY revenue DESC;

-- What is the distribution of sold items across countries?
SELECT dc.country, SUM(quantity) AS quantity_sold FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
GROUP BY dc.country
ORDER BY quantity_sold DESC;


/*
5. Ranking Analysis
   Here we order the values of our dimensions by the measures
   Gives us a view of the top/bottom N items
*/

-- Which 5 products generate the highest revenue
-- Any of the below approaches can be utilised
-- Query 1
SELECT TOP 5
	RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS "rank",
	fs.product_key, 
	dp.product_name, 
	SUM(fs.sales_amount) AS revenue 
FROM 
	gold.fact_sales AS fs
LEFT JOIN 
	gold.dim_products AS dp
ON 
	fs.product_key = dp.product_key
GROUP BY 
	fs.product_key, dp.product_name;

-- Query 2
SELECT TOP 5
	fs.product_key, 
	dp.product_name, 
	SUM(fs.sales_amount) AS revenue 
FROM 
	gold.fact_sales AS fs
LEFT JOIN 
	gold.dim_products AS dp
ON 
	fs.product_key = dp.product_key
GROUP BY 
	fs.product_key, dp.product_name
ORDER BY
	revenue DESC;

-- Query 3
SELECT *
FROM (
SELECT TOP 5
	RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS "rank",
	fs.product_key, 
	dp.product_name, 
	SUM(fs.sales_amount) AS revenue 
FROM 
	gold.fact_sales AS fs
LEFT JOIN 
	gold.dim_products AS dp
ON 
	fs.product_key = dp.product_key
GROUP BY 
	fs.product_key, dp.product_name) AS t
WHERE
	"rank" <= 5;

-- What are the 5 worst-performing products in terms of sales?
-- Any of the below approaches can be utilised
-- Query 1
SELECT TOP 5
	fs.product_key, 
	dp.product_name, 
	SUM(fs.sales_amount) AS revenue 
FROM 
	gold.fact_sales AS fs
LEFT JOIN 
	gold.dim_products AS dp
ON 
	fs.product_key = dp.product_key
GROUP BY 
	fs.product_key, dp.product_name
ORDER BY
	revenue ASC;

-- Query 2
SELECT TOP 5
	RANK() OVER (ORDER BY SUM(fs.sales_amount) ASC) AS "rank",
	fs.product_key, 
	dp.product_name, 
	SUM(fs.sales_amount) AS revenue 
FROM 
	gold.fact_sales AS fs
LEFT JOIN 
	gold.dim_products AS dp
ON 
	fs.product_key = dp.product_key
GROUP BY 
	fs.product_key, dp.product_name;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
	ROW_NUMBER() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS "revenue_rank",
	fs.customer_key,
	dc.first_name,
	dc.last_name,
	SUM(fs.sales_amount) AS revenue
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_customers AS dc
ON
	fs.customer_key = dc.customer_key
GROUP BY
	fs.customer_key, dc.first_name, dc.last_name;

-- Find the 3 customers with the fewest orders placed
-- Any of the below approaches can be used
--Query 1
SELECT TOP 3
	ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT fs.order_number) ASC) AS "rank",
	fs.customer_key,
	dc.first_name,
	dc.last_name,
	COUNT(DISTINCT fs.order_number) AS number_of_orders
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_customers AS dc
ON
	fs.customer_key = dc.customer_key
GROUP BY
	fs.customer_key, dc.first_name, dc.last_name;

-- Query 2
SELECT TOP 3
	fs.customer_key,
	dc.first_name,
	dc.last_name,
	COUNT(DISTINCT fs.order_number) AS number_of_orders
FROM
	gold.fact_sales AS fs
LEFT JOIN
	gold.dim_customers AS dc
ON
	fs.customer_key = dc.customer_key
GROUP BY
	fs.customer_key, dc.first_name, dc.last_name
ORDER BY
	number_of_orders ASC;

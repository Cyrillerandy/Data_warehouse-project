# Data Dictionary for the Gold Layer

## Overview

The Gold Layer of our database represents business-level data that has been structured to support use cases such as analytics and reporting. 

Within it we have a `fact` table and `dimension` tables for specific business metrics.

<hr style = 'background-color:gray; height:3px' />

### 1. gold.dim_customers

- **Purpose:** Stores customer details including gender, demographic and geographic data.

#### Columns:

| Column Name     | Data Type     | Description                                                                              |
|:---------------:|:-------------:|:-----------------------------------------------------------------------------------------|
| customer_key    | INTEGER       | Surrogate Key uniquely identifying each customer record in the customer dimension table. |
| customer_id     | INTEGER       | Unique numerical identifier assigned to each customer.                                   |
| customer_number | NVARCHAR(50)  | Alphanumeric identifier representing the customer, used for tracking and referencing.    |
| first_name      | NVARCHAR(100) | The customer's recorded first name.                                                      |
| last_name       | NVARCHAR(100) | The customer's recorded last name.                                                       |
| country         | NVARCHAR(50)  | The customer's country of residence e.g., Germany.                                       |
| marital_status  | NVARCHAR(50)  | The customer's marital status e.g., 'Married', 'Single'.                                 |
| gender          | NVARCHAR(50)  | The customer's gender e.g., 'Male', 'Female'.                                            |
| birth_date      | DATE          | The customer's date of birth, in the format YYYY-MM-DD e.g., 1971-10-06.                 |
| create_date     | DATE          | The date and time when the customer record was created in the system.                    |

<hr style = 'background-color:gray; height:3px;'/>

### 2. gold.dim_products

- **Purpose:** Stores details about products and gives information on their attributes.

#### Columns:

| Column Name       | Data Type     | Description                                                                                 |
|:-----------------:|:-------------:|:--------------------------------------------------------------------------------------------|
| product_key       | INTEGER       | Surrogate Key uniquely identifying each product record in the product dimension table.      |
| product_id        | INTEGER       | Unique numerical identifier assigned to each product for tracking and referencing.          |
| product_number    | NVARCHAR(50)  | Alphanumeric identifier representing a product, used for categorization or inventory.       |
| product_name      | NVARCHAR(50)  | Descriptive name for the product, including details such as type, colour and size.          |
| category_id       | NVARCHAR(50)  | Unique identifiers for product categories, linking products to higher level classification. |
| category          | NVARCHAR(100) | The category a product belongs to e.g., Accessories, Bikes.                                 |
| subcategory       | NVARCHAR(100) | The subcategory a product belongs to, detailing aspects such as product type.               |
| maintenance       | NVARCHAR(50)  | Indicates whether or not a product require maintenance e.g., 'Yes', 'No'                    |
| product_cost      | INTEGER       | The cost of our product (in $).                                                             |
| product_line      | NVARCHAR(25)  | The specific product line or series the product belongs to e.g., 'Road', ''Mountain'        |
| product_startdate | DATE          | The date when the product became available for sale or use.                                 |

<hr style = 'background-color:gray; height:3px;'>

### 3. gold.fact_sales

- **Purpose:** Stores transactional sales data to be used in analytics.

#### Columns:

| Column Name       | Data Type     | Description                                                                                 |
|:-----------------:|:-------------:|:--------------------------------------------------------------------------------------------|
| order_number      | NVARCHAR(50)  | Unique alphanumeric identifier for each sales order, e.g., 'SO43697'.                       |
| product_key       | INTEGER       | Surrogate key linking an order to the product dimension table.                              | 
| customer_key      | INTEGER       | Surrogate key linking an order to the customer dimension table.                             | 
| order_date        | DATE          | The date when the order was placed.                                                         | 
| shipping_date     | DATE          | The date when the order was shipped to the customer.                                        |
| due_date          | DATE          | The date when the order payment was due.                                                    | 
| sales_amount      | INTEGER       | The amount of money made for the sale of a line item (in $).                                | 
| quantity          | INTEGER       | The number of units of a product ordered for the line item, e.g., 1.                        |
| price             | INTEGER       | Price per unit of the product for the line item, (in $) e.g., 699.                          |










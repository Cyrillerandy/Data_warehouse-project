# Naming Conventions

## Table of Contents

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
    * [Bronze Rules](#bronze-rules)
    * [Silver Rules](#silver-rules)
    * [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
    * [Surrogate Keys](#surrogate-keys)
    * [Technical Columns](#technical-columns)
4. [Stored Procedures](#stored-procedures)

<hr style = "heigth: 3px; background-color: darkgrey;"/>

# General Principles

* **Naming Conventions:** Use snake_case, with lowercase letters and underscores (_) to seperate words.
* **Language:** Use English for all names.
* **Avoid Reserved Words:** Do not use SQL reserved words as object names.

# Table Naming Conventions

## Bronze Rules

* All names must start with the source system name, and table names must match their original names without renaming.
* `<sourcesystem>_<entity>`
    - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
    - `<entity>`: Exact table name from the source system.
    - Example: `crm_customer_info` --> Customer information from the crm system.

## Silver Rules

* All names must start with the source system name, and table names must match their original names without renaming.
* `<sourcesystem>_<entity>`
    - `<sourcesystem>`: Name of the source system (e.g., `crm`, `erp`).
    - `<entity>`: Exact table name from the source system.
    - Example: `crm_customer_info` --> Customer information from the crm system.

## Gold Rules

* All names must use meaningful, business-aligned names for tables, starting with the category prefix. 
* `<category>_<entity>`
    - `<category>`: Describes the role of the table, `dim`(dimension) or `fact`(Fact table).
    - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g. `customers`, `products`, `sales`).
    - Examples:
        * `dim_customers` --> Dimension table for customer data.
        * `fact_sales` --> Fact table conatining sales transactions.

### Glossary of category patterns

| Pattern | Meaning          | Example(s)                           |
|:-------:|:----------------:|:------------------------------------:|
| `dim_`  | Dimension table  | `dim_product`, `dim_customer`        |
| `fact_` | Fact table       | `fact_sales`                         |
| `agg_`  | Aggregated table | `agg_customers`, `agg_sales_monthly` |

# Column Naming Conventions

## Surrogate Keys

* All primary keys in dimension tables must use the suffix `_key`.
* `<table_name>_key`
    - `<table_name>`: Refers to the name of the table/entity the key belongs to.
    - `_key`: A suffix indicating that this is a surrogate key. 
    - Example: `customer_key` --> Surrogate key in the `dim_customers` table. 

## Technical Columns

* All Technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column's purpose.
* `dwh_<column_name>`
    - `dwh`: Prefix exclusively for system-generated metadata.
    - `<column_name>`: Descriptive name indicating the column's purpose.
    - Example: `dwh_load_date` --> System-generated column used to record the date when the record was loaded.

# Stored Procedures

* All stored procedures used for loading data must follow the naming pattern:
* `load_<layer>`.
    - `<layer>`: Represents the layer being loaded, such as `bronze`, `silver` or `gold`.
    - Example: 
        * `load_bronze`: Stored procedure for loading data into the bronze layer.
        * `load_silver`: Stored procedure for loading data into the silver layer. 
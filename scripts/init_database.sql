/*
=================================================================
Create Database and Schemas
=================================================================
Script purpose:
  This script creates a new database named 'DataWarehouse' after checking it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three
  schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
  Running the script will drop the 'DataWarehouse' database if it exists. 
  All the data in the database will be permanently deleted. Proceed cautiously
  and ensure you have backups in place before running this script. 
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' Database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = "DataWarehouse")
BEGIN
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse;
END;
GO

-- Create the database DataWarehouse
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

-- Create the Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

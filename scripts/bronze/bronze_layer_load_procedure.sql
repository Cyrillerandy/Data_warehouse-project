/*
===========================================================================
Stored Proceudre: Load Bronze Layer (From: Source -> To: Bronze Layer)
===========================================================================
Purpose:
  This script is creates a stored procedure that loads data into the
  bronze layer from external CSV files. 
  The script:
  - Truncates the tables in the bronze layer.
  - Loads the data into the bronze layer tables with the `BULK INSERT`
    method, loading all the data from the csv files into the tables.

Parameters:
  None.
  This stored procedure accepts no parameters nor does it return any
  values.

Example Usage:
  EXEC bronze.load_bronze;
===========================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @full_start_time DATETIME, @full_end_time DATETIME;

	BEGIN TRY
		SET @full_start_time = GETDATE();

		PRINT '========================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '========================================================';

		PRINT '--------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '--------------------------------------------------------';
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Udemy Building a data warehouse - Data engineering bootcamp\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\4 - Build Bronze Layer\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration bronze.crm_cust_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting data into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\Udemy Building a data warehouse - Data engineering bootcamp\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\4 - Build Bronze Layer\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration bronze.crm_prd_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting data into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Udemy Building a data warehouse - Data engineering bootcamp\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\4 - Build Bronze Layer\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration bronze.crm_sales_details: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------';

		PRINT '--------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '--------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting data into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\Udemy Building a data warehouse - Data engineering bootcamp\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\4 - Build Bronze Layer\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration bronze.erp_cust_az12: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting data into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\Udemy Building a data warehouse - Data engineering bootcamp\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\4 - Build Bronze Layer\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration bronze.erp_loc_a101: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting data into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\Udemy Building a data warehouse - Data engineering bootcamp\Udemy - Building a Modern Data Warehouse - Data Engineering Bootcamp 2025-3\4 - Build Bronze Layer\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load duration bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------';

		SET @full_end_time = GETDATE();

		PRINT '========================================================';
		PRINT 'Bronze Layer Loading Complete'
		PRINT '>> Total loading time: ' + CAST(DATEDIFF(second, @full_start_time, @full_end_time) AS NVARCHAR) + ' seconds';
		PRINT '========================================================';
	END TRY
	
	BEGIN CATCH
		PRINT 'ERROR ENCOUNTERED DURING BRONZE LAYER LOADING';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH;
END;

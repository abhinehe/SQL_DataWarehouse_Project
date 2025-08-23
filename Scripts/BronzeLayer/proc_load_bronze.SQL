/*
=======================================================================
Stored Procedure : Load Bronze layer (source -> Bronze)
=======================================================================
Script Purpose: 
	This stored procedure load data into 'bronze' from external CSV files
	It performs the following actions:
	-Truncate the bronze tables before loading data 
	-Uses the BULK INSERT command to load data from CSV  Files to bronze layer
Parameters: 
	None
	This stored procedure does not accept any parameters or return any value
Usage Example:
	EXEC bronze.load_bronze;
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
DECLARE @bronze_start datetime, @bronze_end datetime;

DECLARE @start_time datetime, @end_time datetime ,  @diff NVARCHAR(20);



	BEGIN TRY 
	SET @bronze_start = getdate()
		TRUNCATE TABLE bronze.crm_cust_info;
		SET @start_time = getdate();
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\abhijit.nehe\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		SET @diff = CASE
						WHEN	CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR)<50 
							THEN CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR)+'ms'
						ELSE  CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)+'s'
					END
	
		PRINT 'Duration Required :' + @DIFF


		SELECT COUNT(*) FROM Bronze.crm_cust_info;

		TRUNCATE TABLE bronze.crm_prd_info;
		SET @start_time = getdate();
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\abhijit.nehe\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT 'Duration Required :' + CAST(DATEDIFF(second,  @start_time, @end_time) AS NVARCHAR);


		SELECT COUNT(*) FROM Bronze.crm_prd_info;

		TRUNCATE TABLE bronze.crm_sales_details;
		SET @start_time = getdate();
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\abhijit.nehe\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT 'Duration Required :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);

		SELECT COUNT(*) FROM Bronze.crm_sales_details;

		TRUNCATE TABLE Bronze.erp_CUST_AZ12;
		SET @start_time = getdate();
		BULK INSERT Bronze.erp_CUST_AZ12
		FROM 'C:\Users\abhijit.nehe\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT 'Duration Required :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);

		SELECT COUNT(*) FROM Bronze.erp_CUST_AZ12;

		TRUNCATE TABLE Bronze.erp_LOC_A101;
		SET @start_time = getdate();
		BULK INSERT Bronze.erp_LOC_A101
		FROM 'C:\Users\abhijit.nehe\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT 'Duration Required :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);

		SELECT COUNT(*) FROM Bronze.erp_LOC_A101;

		TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2
		SET @start_time = getdate();
		BULK INSERT Bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\abhijit.nehe\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = getdate();
		PRINT 'Duration Required :' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR);
		SET @bronze_end = getdate()
		
		SELECT COUNT(*) FROM Bronze.erp_PX_CAT_G1V2;
		Print 'Loading Bronze layer is completed'
		PRINT 'Duration Required to load a Bronze :' + CAST(DATEDIFF(second, @bronze_start, @bronze_end) AS NVARCHAR);
	END TRY
	BEGIN CATCH 
		PRINT '==================================='
		PRINT 'ERROR OCCURED DURING BRONZE LOADING'
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		print 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR)
		END CATCH 
END




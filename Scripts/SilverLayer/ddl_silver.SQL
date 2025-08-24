/*
=======================================================================
Stored Procedure : Load Silver layer (Bronze -> Silver)
=======================================================================
Script Purpose: 
	This stored procedure load data into 'Silver' from Bronze layer
	It performs the following actions:
	-Truncate the silver tables before loading data 
	-RUn this script to re-define the DDL structure of 'Bronze' Tables 
Parameters: 
	None
	This stored procedure does not accept any parameters or return any value
Usage Example:
	EXEC Silver.load_silver;
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
	DECLARE @start_time	DATETIME , @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY 
	SET @batch_start_time = GETDATE();
	--INSERT DATA INTO SILVER.crm_cust_info
	PRINT'>> Truncating table SILVER.crm_cust_info'
	TRUNCATE TABLE SILVER.crm_cust_info
	PRINT '>> Inserting data into : SILVER.crm_cust_info'
	SET @start_time = GETDATE();
	INSERT INTO silver.crm_cust_info(
	cst_id,	
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
	SELECT 
	cst_id,
	cst_key, 
	TRIM (cst_firstname) AS	first_name,
	TRIM(cst_lastname) AS last_name,	
	CASE 
		WHEN UPPER(TRIM(cst_marital_status ))= 'S'
		THEN 'Single'
		WHEN UPPER(TRIM(cst_marital_status ))  = 'M'
		THEN 'Married'
		ELSE 'n/a'
		END AS cst_marital_status,
	CASE 
		WHEN UPPER(TRIM(cst_gndr))  = 'F'
		THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr )) = 'M' 
		THEN 'Male'
		ELSE 'n/a'
		END AS cst_gender,
	cst_create_date
	FROM (
	SELECT *,
		ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date) AS Flag
	FROM Bronze.crm_cust_info
	WHERE cst_id IS NOT NULL) t 
	WHERE Flag = 1 ;
	SET @end_time = GETDATE();
	PRINT 'DURATION REQUIRED TO LOAD SILVER.cr,_cust_info table:' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR)

	-- INSERT IN SILVER.CRM_PRD_INFO
	PRINT'>> Truncating table SILVER.crm_prd_info'
	TRUNCATE TABLE SILVER.crm_prd_info
	PRINT '>> Inserting data into : SILVER.crm_prd_info'

	INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	SELECT 
	prd_id,	
	REPLACE(SUBSTRING(prd_key,1,5) , '-', '_')  AS cat_id, -- Extract Category ID 
	SUBSTRING(prd_key,7,LEN(prd_key)) AS  prd_key, -- Extract Product key
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,   
	CASE UPPER(TRIM(prd_line))
		WHEN  'M' THEN 'Mountain'
		WHEN  'R' THEN 'Road'
		WHEN  'S' THEN 'Other Sales'
		WHEN  'T' THEN 'Touring'
	ELSE 'n/a'
	END AS prd_line, -- Mapped product line code to descriptive value.
	CAST(prd_start_dt AS date) AS prd_start_dt,
	CAST(LEAD(prd_start_dt)OVER(PARTITION BY prd_key  ORDER BY prd_start_dt)-1 AS DATE)AS prd_end_dt_test
	FROM Bronze.crm_prd_info;

	-- INSERT INTO SILVER.CRM_SALES_DETAILS
	PRINT'>> Truncating table SILVER.crm_sales_details'
	TRUNCATE TABLE SILVER.crm_sales_details
	PRINT '>> Inserting data into : SILVER.crm_sales_details'

	INSERT INTO silver.crm_sales_details
	(sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)
	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8  THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8  THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8  THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
	END AS sls_price
	FROM Bronze.crm_sales_details;

	---- INSERT DATA INTO SILVER.erp_CUST_AZ12
	PRINT'>> Truncating table SILVER.erp_CUST_AZ12'
	TRUNCATE TABLE SILVER.erp_CUST_AZ12
	PRINT '>> Inserting data into : SILVER.erp_CUST_AZ12'

	INSERT INTO SILVER.erp_CUST_AZ12(
	CID,
	BDATE,
	GEN
	)
	SELECT 
	CASE WHEN 
			CID LIKE 'NAS%' 
		THEN SUBSTRING(CID, 4, LEN(CID))
		ELSE CID 
		END AS CID,
		CASE WHEN 
				BDATE > GETDATE() 
				THEN NULL 
				ELSE BDATE 
		END AS BDATE,
		CASE 
		WHEN  UPPER(TRIM(GEN)) IN  ('F', 'FEMALE') THEN 'Female'
		WHEN  UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
		END AS GEN 	
	 FROM BRONZE.erp_CUST_AZ12;

	 --- INSERT DATA INTO SILVER.erp_loc_a101

	PRINT'>> Truncating table SILVER.erp_loc_a101'
	TRUNCATE TABLE SILVER.erp_loc_a101
	PRINT '>> Inserting data into : SILVER.erp_loc_a101'
	INSERT INTO SILVER.erp_loc_a101 (
	CID,
	CNTRY)
	SELECT 
	 REPLACE(CID, '-', '' ) AS CID ,
	 CASE 
			WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
			WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY) = '' THEN 'n/a'
			ELSE CNTRY
	END AS CNTRY
	FROM 
	BRONZE.erp_loc_a101;

	-- INSERT DATE INTO SILVER.erp_PX_CAT_G1V2\
	PRINT'>> Truncating table SILVER.erp_PX_CAT_G1V2'
	TRUNCATE TABLE SILVER.erp_PX_CAT_G1V2
	PRINT '>> Inserting data into : SILVER.erp_PX_CAT_G1V2'
	INSERT INTO SILVER.erp_PX_CAT_G1V2
	(
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	)
	SELECT 
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM BRONZE.erp_PX_CAT_G1V2
	SET @batch_end_time = GETDATE()
	PRINT 'Duration required to load sp :' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS  varchar) 
	END TRY
	BEGIN CATCH
	PRINT 'Error occured' + ERROR_MESSAGE();
	PRINT 'Error Number' +CAST( ERROR_NUMBER() AS NVARCHAR);
	END CATCH 
END


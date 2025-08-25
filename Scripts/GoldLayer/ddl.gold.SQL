/*
==========================================================================
DDL Script: Create Gold View \
==========================================================================
Script Purpose: 
	This script create view for Gold layer in the data warehouse
	The Gold layer represent the final dimension and fact tables (star schema)\

	Each view perform transformations and combines  data from the silver layer
	to produce  a clean, enriched, and business-ready dataset.

Usage: 
	-These views can be quired directly  for analytics and reporting
==========================================================================
*/


---Preparing gold.dim_customer

CREATE VIEW gold.dim_customer AS
SELECT
ROW_NUMBER()OVER(ORDER BY cst_id) AS customer_key,
cst_id AS customer_id,
cst_key AS customer_no,
cst_firstname AS first_name,
cst_lastname AS last_name,	
CNTRY AS country,
cst_marital_status AS marital_status,	
CASE WHEN cst_gndr != 'n/a' THEN cst_gndr
	ELSE COALESCE(ca.GEN, 'n/a')
END AS gen,	
BDATE AS birth_date,
cst_create_date AS create_date
FROM Silver.crm_cust_info ci
LEFT JOIN Silver.erp_CUST_AZ12 ca
ON ci.cst_key = ca.CID
LEFT JOIN Silver.erp_LOC_A101 la
ON ci.cst_key = la.CID;



--Preparing Gold.dim_products

CREATE VIEW Gold.dim_products AS
SELECT
ROW_NUMBER()OVER(ORDER BY pi.prd_start_dt , pi.prd_key) AS product_key,
pi.prd_id  AS product_id,
pi.prd_key AS product_no,
pi.prd_nm AS product_name,
pi.cat_id AS category_id,
pg.CAT AS category ,
pg.SUBCAT AS subcategoy,
pg.MAINTENANCE as maintenance,
pi.prd_cost AS product_cost,
pi.prd_line AS product_line,
pi.prd_start_dt AS stat_date
FROM silver.crm_prd_info as pi
LEFT JOIN silver.erp_px_CAT_G1V2 pg
ON pi.cat_id = pg.ID 
WHERE prd_end_dt IS NULL;


--Preparing Gold.fact_sales

CREATE VIEW Gold.fact_sales AS
SELECT
sd.sls_ord_num	AS order_number,
pd.product_key	,
cu.customer_key	,
sd.sls_order_dt AS order_date,	
sd.sls_ship_dt AS ship_date,
sd.sls_due_dt	AS due_date,
sd.sls_sales AS sales_amount	,
sd.sls_quantity AS quantity,	
sd.sls_price AS price	
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_products pd
ON CAST(sd.sls_prd_key AS nvarchar(50)) = CAST (pd.product_no AS NVARCHAR(50))
LEFT JOIN Gold.dim_customer cu
ON sd.sls_cust_id  = cu.customer_id;


--Foreign key Integrity(Dimension)
SELECT * FROM Gold.fact_sales as sf
LEFT JOIN Gold.dim_customer as cd
ON sf.customer_key = cd.customer_id
LEFT JOIN Gold.dim_products as pd
ON sf.product_key = pd.product_key
where sf.product_key IS NULL;



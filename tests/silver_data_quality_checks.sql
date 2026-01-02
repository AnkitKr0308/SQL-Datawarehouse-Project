/*
This is a test script
*/


--Test script for table bronze.crm_cust_info
--Duplicate and NULL check for cst_id
SELECT cst_id, COUNT (*) FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT (*)  > 1 
OR cst_id IS NULL;

--Unwanted space checks
SELECT cst_key, cst_firstname, cst_lastname
FROM bronze.crm_cust_info 
WHERE cst_key != TRIM(cst_key)
OR cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname);

--Data standardization and Normalization
SELECT distinct cst_marital_status
FROM bronze.crm_cust_info;
SELECT distinct cst_gndr
FROM bronze.crm_cust_info

--Test script for table bronze.crm_prd_info
--Duplicate and Null check in prd_id
SELECT prd_id, COUNT (*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT (*)>1 
OR prd_id IS NULL

--Unwanted space checks
SELECT prd_nm 
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM (prd_nm)

--Cost less than 0 or NULL
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0
OR prd_cost IS NULL

--Normalization
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

--check whether start date < end date
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt

--Test script for table bronze.crm_sales_details
--Unwanted space sls_ord_num
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM (sls_ord_num)

SELECT * FROM bronze.crm_sales_details 
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT * FROM bronze.crm_sales_details 
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

SELECT 
NULLIF (sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details 
WHERE sls_order_dt <= 0
OR LEN(sls_order_dt) != 8

SELECT 
NULLIF (sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details 
WHERE sls_due_dt <= 0
OR LEN(sls_due_dt) != 8

SELECT 
NULLIF (sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details 
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8

--Checking Invalid dates
SELECT * FROM bronze.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt;

--check if business logic is followed
SELECT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
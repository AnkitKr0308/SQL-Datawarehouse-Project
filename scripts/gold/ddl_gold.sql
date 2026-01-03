/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_Customers
GO

CREATE VIEW gold.dim_Customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr -- CRM is the primary source for gender
		ELSE COALESCE (cu.gen, 'NA') -- Fallback to ERP data 
	END AS gender,
	cu.bdate AS birth_date,
	ci.cst_create_date AS created_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 cu
	ON ci.cst_key = cu.cid
LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
GO

-- =============================================================================
-- Create Dimension: gold.dim_Products
-- =============================================================================

DROP VIEW IF EXISTS gold.dim_Products
GO 

CREATE VIEW gold.dim_Products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pr.prd_start_dt, pr.prd_id) AS product_key,
	pr.prd_id AS product_id,
	pr.prd_key product_number,
	pr.prd_nm AS product_name,
	pr.cat_id AS category_id,
	px.cat AS category,
	px.subcat AS subcategory,
	px.maintenance,
	pr.prd_cost AS product_cost,
	pr.prd_line AS product_line,
	pr.prd_start_dt AS start_date
FROM silver.crm_prd_info pr
LEFT JOIN silver.erp_px_cat_g1v2 px
	ON pr.cat_id = px.id
WHERE prd_end_dt IS NULL
GO


-- =============================================================================
-- Create Fact: gold.fact_Sales
-- =============================================================================

DROP VIEW IF EXISTS gold.fact_Sales
GO

CREATE VIEW gold.fact_Sales AS
SELECT 
	sls_ord_num AS order_number,
	pr.product_key AS product_key,
	cu.customer_key AS customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_price,
	sls_quantity AS quantity,
	sls_price AS price	
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_Customers cu
	ON cu.customer_id = sd.sls_cust_id
LEFT JOIN gold.dim_Products pr
	ON pr.product_number = sd.sls_prd_key
GO
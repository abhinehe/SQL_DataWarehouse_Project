--Foreign key Integrity(Dimension)
SELECT * FROM Gold.fact_sales as sf
LEFT JOIN Gold.dim_customer as cd
ON sf.customer_key = cd.customer_id
LEFT JOIN Gold.dim_products as pd
ON sf.product_key = pd.product_key
where sf.product_key IS NULL;

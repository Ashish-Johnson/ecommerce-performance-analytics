-- =====================================
-- ORDER-LEVEL DUPLICATE CHECK
-- =====================================

SELECT 
	order_id,
	count(*) AS cnt_order_id
FROM ecommerce_order_level
GROUP BY order_id
HAVING count(*) >1;
	
-- =====================================
-- ORDER-LEVEL VALIDATION CHECK
-- =====================================
	
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM ecommerce_order_level;

-- =====================================
-- REVENUE RECONCILIATION CHECK
-- =====================================

SELECT 
	SUM(total_payment)
FROM ecommerce_order_level;

SELECT 
	SUM(payment_value)
FROM olist_order_payments_dataset;

-- =====================================
-- NULL CHECKS: ORDER-LEVEL TABLE
-- =====================================

SELECT 
	COUNT(*) 
		FILTER (WHERE order_id IS NULL) 
			AS order_id_cnt,
	COUNT(*) 
		FILTER (WHERE customer_id IS NULL) 
			AS customer_id_cnt,
	COUNT(*) 
		FILTER (WHERE order_purchase_date IS NULL) 
			AS order_purchase_date_cnt,
	COUNT(*) 
		FILTER (WHERE delivered_date IS NULL) 
			AS delivered_date_cnt,
	COUNT(*) 
		FILTER (WHERE estimated_delivery_date IS NULL)
			AS estimated_delivery_date_cnt,
	COUNT(*) 
		FILTER (WHERE customer_unique_id IS NULL) 
			AS customer_unique_id_cnt,
	COUNT(*) 
		FILTER (WHERE customer_city IS NULL) 
			AS customer_city_cnt,
	COUNT(*) 
		FILTER (WHERE total_payment IS NULL) 
			AS total_payment_cnt,
	COUNT(*) 
		FILTER (WHERE delivery_performance IS NULL) 
			AS delivery_performance_cnt
FROM ecommerce_order_level;

-- =====================================
-- NULL CHECKS: ITEM-LEVEL TABLE
-- =====================================
	
SELECT 
	COUNT(*) 
		FILTER (WHERE order_id IS NULL) 
			AS order_id_cnt,
	COUNT(*) 
		FILTER (WHERE customer_id IS NULL) 
			AS customer_id_cnt,
	COUNT(*) 
		FILTER (WHERE order_purchase_date IS NULL) 
			AS order_purchase_date_cnt,
	COUNT(*) 
		FILTER (WHERE delivered_date IS NULL) 
			AS delivered_date_cnt,
	COUNT(*) 
		FILTER (WHERE estimated_delivery_date IS NULL) 
			AS estimated_delivery_date_cnt,
	COUNT(*) 
		FILTER (WHERE customer_unique_id IS NULL) 
			AS customer_unique_id_cnt,
	COUNT(*) 
		FILTER (WHERE customer_city IS NULL) 
			AS customer_city_cnt,
	COUNT(*)
		FILTER (WHERE order_item_id IS NULL) 
			AS order_item_id_cnt,
	COUNT(*)
		FILTER (WHERE product_id IS NULL) 
			AS product_id_cnt,
	COUNT(*) 
		FILTER (WHERE price IS NULL) 
			AS price_cnt,
	COUNT(*) 
		FILTER (WHERE freight_value IS NULL) 
			AS freight_value_cnt,
	COUNT(*) 
		FILTER (WHERE shipping_ratio IS NULL) 
			AS shipping_ratio_cnt,
	COUNT(*)
		FILTER (WHERE product_category_name IS NULL) 
			AS product_category_name_cnt,
	COUNT(*)
		FILTER (WHERE product_category_name_english IS NULL) 
			AS product_category_name_english_cnt,
	COUNT(*) 
		FILTER (WHERE product_name_length IS NULL)
			AS product_name_length_cnt,
	COUNT(*) 
		FILTER (WHERE product_description_length IS NULL) 
			AS product_description_length_cnt,
	COUNT(*)
		FILTER (WHERE delivery_performance IS NULL)
			AS delivery_performance_cnt,
	COUNT(*) 
		FILTER (WHERE product_name_group IS NULL) 
			AS product_name_group_cnt,
	COUNT(*) 
		FILTER (WHERE product_description_group IS NULL)
			AS product_description_group_cnt
FROM ecommerce_order_item_level;

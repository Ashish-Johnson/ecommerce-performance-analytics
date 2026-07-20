-- =====================================
-- BASE TABLE FOR ORDER-LEVEL GRAIN
-- =====================================
-- Purpose:
-- Create curated order-level analytical table
-- for revenue, customer, and retention analysis.

-- Grain:
-- One row per order_id

DROP TABLE IF EXISTS ecommerce_order_level;

CREATE TABLE ecommerce_order_level AS 
	WITH payment_summary AS(
		SELECT 
			order_id,
			SUM(payment_value) AS total_payment
		FROM olist_order_payments_dataset
    	GROUP BY order_id
	)
	SELECT
		
		-- Order info
	    o.order_id,
	    o.customer_id,
	    o.order_purchase_timestamp::DATE 
			AS order_purchase_date,
	    o.order_delivered_customer_date::DATE 
			AS delivered_date,
		o.order_estimated_delivery_date::DATE 
			AS estimated_delivery_date,
		
		-- Customer info
	    c.customer_unique_id,
	    c.customer_city,
		
		-- Payment info
		ps.total_payment,
	
		-- Delivery flag
		CASE 
	        WHEN o.order_delivered_customer_date
				<= o.order_estimated_delivery_date 
					THEN 'On-Time'
	        WHEN o.order_delivered_customer_date 
				> o.order_estimated_delivery_date 
					THEN 'Late'
	        ELSE 'Pending/Canceled'
	    END AS delivery_performance
	FROM olist_orders_dataset o
	JOIN olist_customers_dataset c
    	ON o.customer_id = c.customer_id
	LEFT JOIN payment_summary ps
    	ON o.order_id = ps.order_id;

-- =====================================
-- BASE TABLE FOR ITEM-LEVEL GRAIN
-- =====================================

-- Purpose:
-- Create curated item-level analytical table
-- for product, category, freight, and shipping analysis.

-- Grain:
-- One row per order item

DROP TABLE IF EXISTS ecommerce_order_item_level;

CREATE TABLE ecommerce_order_item_level AS
	WITH percentiles AS (
		SELECT 
			percentile_cont(0.25) 
				WITHIN GROUP(ORDER BY product_name_length)
					AS name_p25,
			percentile_cont(0.75) 
				WITHIN GROUP(ORDER BY product_name_length) 
					AS name_p75,
			percentile_cont(0.25) 
				WITHIN GROUP(ORDER BY product_description_length)
					AS desc_p25,
			percentile_cont(0.75)
				WITHIN GROUP(ORDER BY product_description_length)
					AS desc_p75
		FROM olist_products_dataset
		WHERE product_name_length IS NOT NULL 
		AND product_description_length IS NOT NULL
	)
	
	SELECT
	    -- Order info
	    o.order_id,
	    o.customer_id,
	    o.order_purchase_timestamp::DATE 
			AS order_purchase_date,
	    o.order_delivered_customer_date::DATE 
			AS delivered_date,
	    o.order_estimated_delivery_date::DATE 
			AS estimated_delivery_date,
	
	    -- Customer info
	    c.customer_unique_id,
	    c.customer_city,
	
	    -- Item info
	    oi.order_item_id,
	    oi.product_id,
	    oi.price,
	    oi.freight_value,
	
	    -- Shipping metric
	    (oi.freight_value / 
			NULLIF(oi.price, 0)) 
				AS shipping_ratio,
	
	    -- Product info
	    p.product_category_name,
	    pt.product_category_name_english,
	
	    p.product_name_length,
	    p.product_description_length,
	
	    -- Delivery flag
	   	CASE 
	        WHEN o.order_delivered_customer_date
				<= o.order_estimated_delivery_date 
					THEN 'On-Time'
	        WHEN o.order_delivered_customer_date 
				> o.order_estimated_delivery_date 
					THEN 'Late'
	        ELSE 'Pending/Canceled'
		END AS delivery_performance,
	
		-- Name length category
		CASE
			WHEN p.product_name_length 
				IS NULL 
					THEN 'missing'
			WHEN p.product_name_length 
				<= pr.name_p25 
					THEN 'short'
			WHEN p.product_name_length 
				<= pr.name_p75 
					THEN 'medium'
			ELSE 'long'
		END AS product_name_group,
		
	 -- Description length category
		CASE
			WHEN p.product_description_length  
				IS NULL 
					THEN 'missing'
			WHEN p.product_description_length 
				<= pr.desc_p25 
					THEN 'short'
			WHEN p.product_description_length 
				<= pr.desc_p75
					THEN 'medium'
			ELSE 'long'
		END AS product_description_group
	FROM olist_orders_dataset o
	JOIN olist_customers_dataset c
		ON o.customer_id = c.customer_id
	JOIN olist_order_items_dataset oi
	    ON o.order_id = oi.order_id
	LEFT JOIN olist_products_dataset p
	    ON oi.product_id = p.product_id
	CROSS JOIN percentiles pr
	LEFT JOIN product_category_name_translation pt
	    ON p.product_category_name = pt.product_category_name;
	
	

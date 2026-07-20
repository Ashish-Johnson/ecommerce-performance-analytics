-- =====================================
-- DELIVERY WINDOW ANALYSIS
-- =====================================

-- Objective:
-- Analyze estimated delivery windows associated
-- with highest revenue concentration.

CREATE OR REPLACE VIEW vw_delivery_window AS
	WITH  delivery_window AS (
		SELECT 
		  estimated_delivery_date - order_purchase_date
				AS estimated_window,
		ROUND(SUM(total_payment),2) AS revenue
		FROM ecommerce_order_level
		GROUP BY estimated_window
	),
	top10 AS (
		SELECT 
			estimated_window,
			revenue
		FROM delivery_window
		ORDER BY revenue DESC
		LIMIT 10
	)
	SELECT 
		estimated_window,
		revenue
	FROM top10;

-- =====================================
-- DELIVERY PERFORMANCE ANALYSIS
-- =====================================

-- Objective:
-- Compare commercial performance between
-- on-time and late deliveries.

CREATE OR REPLACE VIEW vw_delivery_performance AS
	SELECT delivery_performance,
		SUM(total_payment) AS revenue,
		ROUND(AVG(total_payment),2) AS AOV,
		COUNT(order_id) AS total_orders
	FROM ecommerce_order_view
	WHERE delivery_performance != 'Pending/Canceled'
	GROUP BY delivery_performance
	ORDER BY revenue DESC;

-- =====================================
-- SHIPPING BURDEN ANALYSIS
-- =====================================

-- Objective:
-- Analyze relationship between shipping burden
-- and commercial performance.

-- Important Note:
-- Freight aggregated at order level before
-- ratio calculation to preserve correct grain.

CREATE OR REPLACE VIEW vw_shipping_burden AS
	WITH freight_cost AS(
		SELECT order_id,
			COUNT(order_item_id) AS item_count,
			SUM(freight_value) AS total_freight
		FROM ecommerce_order_item_view
		GROUP BY order_id
	),
	ratio AS (
		SELECT 
			f.order_id,
			f.total_freight,
			e.total_payment,
			f.item_count,
			ROUND((f.total_freight/
				NULLIF(e.total_payment, 0))*100,2) 
					AS shipping_ratio
		FROM freight_cost f
		JOIN ecommerce_order_view e
		ON f.order_id = e.order_id
	)
	SELECT 
		CASE
	        WHEN shipping_ratio <= 25 
				THEN '0-25%'
	        WHEN shipping_ratio <= 50 
				THEN '25-50%'
	        ELSE '50%+'
	    END AS shipping_bucket,
		COUNT(*) AS total_orders,
		ROUND(AVG(total_payment),2) AS AOV,
		SUM(total_payment) AS revenue
	FROM ratio    
	GROUP BY shipping_bucket
	ORDER BY total_orders DESC;

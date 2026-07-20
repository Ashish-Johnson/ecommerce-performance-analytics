-- =====================================
-- CUSTOMER PURCHASE BEHAVIOR ANALYSIS
-- =====================================

-- Objective:
-- Compare one-time and repeat customer
-- contribution to revenue and order volume.

CREATE OR REPLACE VIEW vw_customer_behavior AS
	WITH customer AS (
		SELECT 
			customer_unique_id, 
			COUNT(order_id) AS total_orders,
			SUM(total_payment) AS revenue
	FROM ecommerce_order_view
	GROUP BY customer_unique_id
	)
	SELECT 
		CASE 
			WHEN total_orders = 1
				THEN 'One-Time Customer'
			ELSE 'Repeat Customer'
		END AS customer_type,
		COUNT(customer_unique_id) AS customers,
		SUM(revenue) AS total_revenue,
		ROUND(AVG(revenue),2) AS avg_customer_value,
		SUM(total_orders) AS total_orders
	FROM customer
	GROUP BY customer_type
	ORDER BY total_revenue DESC;

-- =====================================
-- CUSTOMER SEGMENTATION ANALYSIS
-- =====================================

-- Objective:
-- Segment customers based on monetary value,
-- purchase frequency, and recency behavior.
	
CREATE OR REPLACE VIEW vw_customer_segmentation AS
	WITH customer_rfm AS (
		SELECT
	        customer_unique_id,
			MAX(order_purchase_date) AS last_purchase_date,
			COUNT(order_id) AS frequency,
			ROUND(SUM(total_payment), 2) AS monetary
		FROM ecommerce_order_view
		GROUP BY customer_unique_id
	),
	percentiles AS (
		SELECT 
			percentile_cont(0.25)
				WITHIN GROUP (ORDER BY monetary) AS p25,
			percentile_cont(0.70)
				WITHIN GROUP (ORDER BY monetary) AS p75
		FROM customer_rfm	
	),
	max_date AS (
		SELECT 
			MAX(last_purchase_date) AS max_date
		FROM customer_rfm
	),
	customer_segments AS (
		SELECT customer_unique_id,
			CASE
				WHEN c.monetary >= p.p75
					THEN 'High Value Customer'
				WHEN c.monetary >= p.p25
					THEN 'Moderate Value Customer'
				ELSE 'Low Value Customer'
			END AS value_type,
			CASE
				WHEN m.max_date - c.last_purchase_date > 90
					THEN 'Old Customer'
				ELSE 'Recent Customer'
			END AS Recency_type,
			CASE
				WHEN c.frequency > 2 
					THEN 'Loyal Customer'
				WHEN c.frequency > 1
					THEN 'Repeat Customer'
				ELSE 'One-Time Customer'
			END AS frequency_type
		FROM customer_rfm c
		CROSS JOIN percentiles p
		CROSS JOIN max_date m
	)
	SELECT 
		value_type,
		recency_type,
		frequency_type,
		COUNT(*) AS total_customers,
		ROUND((COUNT(*)*100/
	    	SUM(COUNT(*)) OVER ()),2) 
				AS customer_percentage
	FROM customer_segments
	GROUP BY 
		value_type,
		recency_type,
		frequency_type
	ORDER BY total_customers DESC;
		
-- =====================================
-- NEW VS REPEAT CUSTOMER TREND ANALYSIS
-- =====================================

-- Objective:
-- Compare monthly commercial contribution
-- between new and repeat customers.

CREATE OR REPLACE VIEW vw_new_vs_repeat_customers AS
	WITH first_purchase AS (
		SELECT
			customer_unique_id,
			MIN(order_purchase_date) AS first_purchase_date
		FROM ecommerce_order_view
		GROUP BY customer_unique_id
	),
	customer_orders AS (
		SELECT
			e.customer_unique_id,
			e.order_id,
			e.order_purchase_date,
			TO_CHAR(e.order_purchase_date,'YYYY-MM') AS order_month,
			e.total_payment,
			CASE
				WHEN e.order_purchase_date = f.first_purchase_date
					THEN 'New Customer'
				ELSE 'Repeat Customer'
			END AS customer_type
		FROM ecommerce_order_view e
		JOIN first_purchase f
		ON e.customer_unique_id = f.customer_unique_id
	)
	SELECT
		order_month,
		customer_type,
		COUNT(order_id) AS total_orders,
		ROUND(SUM(total_payment), 2) AS revenue,
		ROUND(AVG(total_payment), 2) AS AOV,
		COUNT(DISTINCT customer_unique_id) AS customers
	FROM customer_orders
	WHERE order_purchase_date >= '2017-01-01'
    AND order_purchase_date <= '2018-09-01'
	GROUP BY
		order_month,
		customer_type
	ORDER BY
		order_month,
		customer_type;

-- =====================================
-- CUSTOMER REVENUE CONCENTRATION ANALYSIS
-- =====================================

-- Objective:
-- Analyze revenue concentration across
-- customer value segments.

CREATE OR REPLACE VIEW vw_customer_pareto AS
	WITH customer_rfm AS (
	    SELECT
	        customer_unique_id,
	        ROUND(SUM(total_payment), 2) AS monetary
	    FROM ecommerce_order_view
	    GROUP BY customer_unique_id
	),
	percentiles AS (
	    SELECT 
	        percentile_cont(0.25)
	            WITHIN GROUP (ORDER BY monetary) AS p25,
	        percentile_cont(0.70)
	            WITHIN GROUP (ORDER BY monetary) AS p75
	    FROM customer_rfm
	),
	customer_segments AS (
	    SELECT
	        customer_unique_id,
	        monetary,
	        CASE
	            WHEN monetary >= p.p75
	                THEN 'High Value Customer'
	            WHEN monetary >= p.p25
	                THEN 'Moderate Value Customer'
	            ELSE 'Low Value Customer'
	        END AS value_type
	    FROM customer_rfm c
	    CROSS JOIN percentiles p
	),
	segment_summary AS (
	    SELECT
	        value_type,
	        COUNT(*) AS total_customers,
	        ROUND(SUM(monetary), 2) AS revenue
	    FROM customer_segments
	    GROUP BY value_type
	)
	SELECT
	    value_type,
		revenue,
		total_customers,
	    ROUND(revenue * 100.0/
			NULLIF(SUM(revenue) OVER (),0),2)
				AS revenue_percent,
	    ROUND((SUM(revenue) 
			OVER (ORDER BY revenue DESC)* 100.0)/
	        	NULLIF(SUM(revenue) OVER (),0),2)
					AS cumulative_revenue_percent
	FROM segment_summary
	ORDER BY revenue DESC;
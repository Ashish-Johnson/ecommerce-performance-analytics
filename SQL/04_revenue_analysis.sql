-- =====================================
-- INITIAL MONTHLY REVENUE EXPLORATION
-- =====================================

-- Important Note:
-- Revenue observations for the first 3 months 
-- and last 2 months appear incomplete 
-- due to partial dataset coverage.

SELECT 
	TO_CHAR(order_purchase_date, 'YYYY-MM') AS month_year,
	SUM(total_payment) AS monthly_revenue
FROM ecommerce_order_view 
GROUP BY month_year
ORDER BY month_year;

-- =====================================
-- MONTHLY REVENUE TREND ANALYSIS
-- =====================================
-- Objective:
-- Create reusable monthly revenue summary
-- dataset for trend and performance analysis.

CREATE OR REPLACE VIEW vw_monthly_revenue AS
	SELECT 
		TO_CHAR(order_purchase_date,'YYYY-MM') AS month_year,
		SUM(total_payment) AS revenue,
		ROUND(AVG(total_payment), 2) AS AOV,
		COUNT(order_id) AS total_orders
	FROM ecommerce_order_view
	WHERE order_purchase_date >= '2017-01-01' 
		AND order_purchase_date <= '2018-09-01' 
	GROUP BY month_year
	ORDER BY month_year;
	
-- =====================================
-- ROLLING REVENUE TREND ANALYSIS
-- =====================================
-- Objective:
-- Create smoothed monthly revenue trend
-- dataset using 3-month rolling averages.

CREATE OR REPLACE VIEW vw_rolling_revenue AS	
	WITH monthly_revenue AS (
		SELECT
			TO_CHAR(order_purchase_date,'YYYY-MM') AS month_year,
			SUM(total_payment) AS revenue
		FROM ecommerce_order_view
		WHERE order_purchase_date >= '2017-01-01'
	    AND order_purchase_date < '2018-09-01'
		GROUP BY month_year
	)
	SELECT 
		month_year,
		revenue,
		ROUND(
		AVG(revenue) 
		OVER(ORDER BY month_year 
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2)
				AS month_3_rolling_avg
	FROM monthly_revenue
	ORDER BY month_year;

-- =====================================
-- TOP CUSTOMER CITIES BY REVENUE
-- =====================================
-- Objective:
-- Create customer purchase behavior dataset
-- comparing one-time and repeat customers.

CREATE OR REPLACE VIEW vw_top_city_revenue AS
	SELECT customer_city,
		SUM(total_payment) AS revenue,
		ROUND(AVG(total_payment),2) AS AOV,
		COUNT(order_id) AS total_orders
	FROM ecommerce_order_view
	GROUP BY customer_city
	ORDER BY revenue DESC;
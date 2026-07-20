-- =====================================
-- PRODUCT DESCRIPTION LENGTH ANALYSIS
-- =====================================

-- Objective:
-- Analyze relationship between product
-- description length and commercial performance.

CREATE OR REPLACE VIEW vw_product_description_analysis AS
	SELECT
	    product_description_group,
	    COUNT(*) AS total_items,
	    ROUND(AVG(price), 2) AS avg_item_price,
	    ROUND(SUM(price), 2) AS revenue
	FROM ecommerce_order_item_view
	WHERE product_description_group != 'missing'
	GROUP BY product_description_group
	ORDER BY revenue DESC;

-- =====================================
-- PRODUCT NAME LENGTH ANALYSIS
-- =====================================

-- Objective:
-- Analyze relationship between product
-- name length and commercial performance.
CREATE OR REPLACE VIEW vw_product_name_analysis AS
	SELECT
	    product_name_group,
	    COUNT(*) AS total_items,
	    ROUND(AVG(price), 2) AS avg_item_price,
	    ROUND(SUM(price), 2) AS revenue
	FROM ecommerce_order_item_view
	WHERE product_name_group != 'missing'
	GROUP BY product_name_group
	ORDER BY revenue DESC;
		
-- =====================================
-- CATEGORY REVENUE CONCENTRATION ANALYSIS
-- =====================================

-- Objective:
-- Identify revenue concentration across
-- product categories using Pareto analysis.

CREATE OR REPLACE VIEW vw_category_pareto AS	
	WITH cat_rev AS (
		SELECT 
			product_category_name_english AS category,
			sum(price) AS revenue
		FROM ecommerce_order_item_level
		GROUP BY product_category_name_english
		ORDER BY revenue DESC
	),
	pareto AS (
		SELECT
			category,
			revenue,
			SUM(revenue) 
				OVER(ORDER BY revenue DESC) 
					AS cumulative_rev,
			SUM(revenue) OVER() AS total_rev
		FROM cat_rev	
	)
	SELECT
		category,
		revenue,
		ROUND(cumulative_rev,2) AS cumulative_revenue,
		total_rev,
		ROUND((cumulative_rev/total_rev)*100,2)
			AS cumulative_percentage
	FROM pareto
	ORDER BY revenue DESC;

-- =====================================
-- CATEGORY AVERAGE ITEM VALUE ANALYSIS
-- =====================================

-- Objective:
-- Compare product categories based on
-- average item value and sales volume.

CREATE OR REPLACE VIEW vw_category_item_value AS
	SELECT product_category_name_english,
		SUM(price) AS revenue,
		ROUND(AVG(price),2) AS avg_item_value,
		COUNT (order_item_id) AS total_items_sold
	FROM ecommerce_order_item_view
	GROUP BY product_category_name_english
	ORDER BY avg_item_value DESC;

-- =====================================
-- CATEGORY REVENUE PERFORMANCE ANALYSIS
-- =====================================

-- Objective:
-- Identify top revenue-generating product
-- categories and sales contribution.

CREATE OR REPLACE VIEW vw_category_revenue_analysis AS
	SELECT product_category_name_english,
		SUM(price) AS revenue,
		ROUND(AVG(price),2) AS avg_item_value,
		COUNT (order_item_id) AS total_items_sold
	FROM ecommerce_order_item_view
	GROUP BY product_category_name_english
	ORDER BY revenue DESC;
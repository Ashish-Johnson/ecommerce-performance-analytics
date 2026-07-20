-- =====================================
-- CORE ORDER-LEVEL VIEW
-- =====================================

-- Purpose:
-- Create simplified reusable order-level view
-- for revenue, customer, retention, and
-- operational analysis.

-- Grain:
-- One row per order_id

-- Important Note:
-- View excludes item-level attributes to
-- preserve correct order-level aggregation.

CREATE VIEW ecommerce_order_view AS
	SELECT
		order_id,
		customer_id,
		order_purchase_date,
		customer_unique_id,
		customer_city,
		total_payment,
		delivery_performance
	FROM ecommerce_order_level;

-- =====================================
-- CORE ITEM-LEVEL VIEW
-- =====================================

-- Purpose:
-- Create simplified reusable item-level view
-- for product, category, freight, and
-- shipping analysis.

-- Grain:
-- One row per order item

-- Important Note:
-- Item-level records may duplicate order_id.
-- Order-level revenue analysis should use
-- ecommerce_order_view instead.

CREATE VIEW ecommerce_order_item_view AS
	SELECT
		order_id,
		customer_id,
		order_purchase_date,
		customer_unique_id,
		customer_city,
		order_item_id,
		product_id,
		price,
		freight_value,
		shipping_ratio,
		product_category_name,
		product_category_name_english,
		delivery_performance,
		product_name_group,
		product_description_group
	FROM ecommerce_order_item_level;
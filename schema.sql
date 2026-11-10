-- =====================================================================================
-- schema.sql — Duka Smart Electronics, retail_analytics database
--
-- Based on the provided 02_create_tables.sql, tightened so bad data cannot get in:
--   * NOT NULL on every column the analysis depends on (a NULL price or status would
--     silently drop out of revenue totals).
--   * City restricted to the ten towns the company trades in.
--   * Product category restricted to the five known categories.
--   * Extra indexes on the columns most queries filter or group by.
--
-- Run connected to retail_analytics:
--   psql -U postgres -d retail_analytics -f schema.sql
-- (Create the database first:  CREATE DATABASE retail_analytics;)
-- =====================================================================================

-- Uncomment to rebuild from scratch (this deletes the data):
-- DROP VIEW  IF EXISTS monthly_sales_summary;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS customers;

CREATE TABLE IF NOT EXISTS customers (
    customer_id        INTEGER       PRIMARY KEY,
    customer_name      VARCHAR(100)  NOT NULL,
    gender             VARCHAR(10)   CHECK (gender IN ('Male', 'Female')),
    city               VARCHAR(50)   NOT NULL
                       CHECK (city IN ('Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret',
                                       'Thika', 'Nyeri', 'Meru', 'Machakos', 'Kiambu')),
    registration_date  DATE          NOT NULL,
    customer_segment   VARCHAR(20)   NOT NULL
                       CHECK (customer_segment IN ('Retail', 'Corporate', 'VIP'))
);

CREATE TABLE IF NOT EXISTS orders (
    order_id          INTEGER        PRIMARY KEY,
    customer_id       INTEGER        NOT NULL REFERENCES customers (customer_id),
    order_date        DATE           NOT NULL,
    product_name      VARCHAR(100)   NOT NULL,
    product_category  VARCHAR(50)    NOT NULL
                      CHECK (product_category IN ('Electronics', 'Accessories', 'Home Appliances',
                                                  'Computing', 'Mobile Phones')),
    quantity          INTEGER        NOT NULL CHECK (quantity > 0),
    unit_price        NUMERIC(12,2)  NOT NULL CHECK (unit_price >= 0),
    cost_price        NUMERIC(12,2)  NOT NULL CHECK (cost_price >= 0),
    discount          NUMERIC(5,2)   NOT NULL DEFAULT 0 CHECK (discount BETWEEN 0 AND 100),
    payment_method    VARCHAR(30)    NOT NULL
                      CHECK (payment_method IN ('M-Pesa', 'Cash', 'Card', 'Bank Transfer')),
    order_status      VARCHAR(20)    NOT NULL
                      CHECK (order_status IN ('Completed', 'Pending', 'Cancelled'))
);

-- Joins on customer and date filters/grouping are in almost every query.
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders (customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_date     ON orders (order_date);
-- Nearly every money question filters on status; category is the most common GROUP BY.
CREATE INDEX IF NOT EXISTS idx_orders_status   ON orders (order_status);
CREATE INDEX IF NOT EXISTS idx_orders_category ON orders (product_category);
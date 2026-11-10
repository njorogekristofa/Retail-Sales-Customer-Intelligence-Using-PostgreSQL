-- Q1: Retrieve all customer records
SELECT * from customers c ;

-- Q2: Display customer names, cities, and segments
SELECT customer_name , city, customer_segment 
from customers;


--3. Find customers living in Nairobi.
SELECT *
FROM customers
WHERE city = 'Nairobi'
ORDER BY customer_name;

--4. Find customers registered after January 1, 2025.
SELECT *
FROM customers
WHERE registration_date > DATE '2025-01-01'
ORDER BY registration_date;

--5. Display all unique customer cities.
SELECT DISTINCT city
FROM customers
ORDER BY city;

--6. Retrieve the 10 most recent orders.
SELECT *
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 10;
--7. Find orders with unit prices above KSh 10,000.
SELECT order_id, order_date, product_name, product_category, unit_price
FROM orders
WHERE unit_price > 10000
ORDER BY unit_price DESC, order_id;

--8. Find customers whose names start with A.
SELECT *
FROM customers
WHERE customer_name LIKE 'A%'
ORDER BY customer_name;

--9. Retrieve orders with quantities between 2 and 5.
SELECT *
FROM orders
WHERE quantity BETWEEN 2 AND 5
ORDER BY quantity, order_id;

--10. Find orders paid through M-Pesa.
SELECT *
FROM orders
WHERE payment_method = 'M-Pesa'
ORDER BY order_date, order_id;

--11. Count all customers.
SELECT COUNT(*) AS total_customers
FROM customers;

--12. Count all orders.
SELECT COUNT(*) AS total_orders
FROM orders;

--13. Calculate completed-order revenue.
SELECT ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS completed_revenue
FROM orders
WHERE order_status = 'Completed';

--14. Calculate the average completed-order value.
SELECT ROUND(AVG(quantity * unit_price * (1 - discount / 100)), 2) AS avg_completed_order_value
FROM orders
WHERE order_status = 'Completed';

--15. Find the highest and lowest product prices.
'''SELECT MAX(unit_price) AS highest_unit_price,
       MIN(unit_price) AS lowest_unit_price
FROM orders;'''

--16. Calculate revenue by product category.
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;

--17. Count customers by city.
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;


--18. Calculate quantity sold by product.
SELECT product_name, product_category,
       SUM(quantity) AS units_sold
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_name, product_category
ORDER BY units_sold DESC, product_name;


--19. Find categories generating more than KSh 100,000 in revenue.
SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2) AS revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING SUM(quantity * unit_price * (1 - discount / 100)) > 100000
ORDER BY revenue DESC;



--20. Calculate the percentage of cancelled orders.
SELECT COUNT(*) FILTER (WHERE order_status = 'Cancelled')                          AS cancelled_orders,
       COUNT(*)                                                                    AS total_orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE order_status = 'Cancelled') / COUNT(*), 2) AS cancelled_pct
FROM orders;

--21. Display orders with customer names and cities.
SELECT o.order_id, o.order_date, c.customer_name, c.city,
       o.product_name, o.quantity, o.order_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_date, o.order_id;

--22. Calculate total spending by customer.
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment,
       COALESCE(ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2), 0) AS total_spending
FROM customers c
LEFT JOIN orders o
       ON o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.city, c.customer_segment
ORDER BY total_spending DESC, c.customer_id;

--23. Identify customers who have never ordered.
SELECT c.*
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

--24. Find the 10 highest-spending customers.
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS total_spending
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.city, c.customer_segment
ORDER BY total_spending DESC
LIMIT 10;

--25. Calculate revenue by customer city.
SELECT c.city,
       COUNT(DISTINCT o.customer_id)                                       AS paying_customers,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 2) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.city
ORDER BY revenue DESC;

--26. Identify customers with more than five orders.
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment,
       COUNT(*) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.city, c.customer_segment
HAVING COUNT(*) > 5
ORDER BY order_count DESC, c.customer_id;

--27. Calculate average customer spending by segment.
WITH customer_totals AS (
    SELECT o.customer_id,
           SUM(o.quantity * o.unit_price * (1 - o.discount / 100)) AS total_spending
    FROM orders o
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT c.customer_segment,
       COUNT(*)                          AS purchasing_customers,
       ROUND(AVG(ct.total_spending), 2)  AS avg_spending_per_customer,
       ROUND(SUM(ct.total_spending), 2)  AS segment_revenue
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
GROUP BY c.customer_segment
ORDER BY avg_spending_per_customer DESC;

--28. Identify the most popular category among VIP customers.
SELECT o.product_category,
       COUNT(*)                                       AS vip_orders,
       SUM(o.quantity)                                AS vip_units,
       ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100))
             FILTER (WHERE o.order_status = 'Completed'), 2) AS vip_completed_revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'VIP'
GROUP BY o.product_category
ORDER BY vip_orders DESC, vip_units DESC
LIMIT 1;

--29. Find customers spending above the average total spending per purchasing customer.
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.customer_segment,
       ROUND(ct.total_spending, 2)                                    AS total_spending,
       ROUND((SELECT AVG(total_spending) FROM customer_totals), 2)    AS avg_per_purchasing_customer
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
WHERE ct.total_spending > (SELECT AVG(total_spending) FROM customer_totals)
ORDER BY ct.total_spending DESC;


--30. Find products priced above the overall average unit price.
SELECT DISTINCT product_name, product_category, unit_price,
       ROUND((SELECT AVG(unit_price) FROM orders), 2) AS overall_avg_unit_price
FROM orders
WHERE unit_price > (SELECT AVG(unit_price) FROM orders)
ORDER BY unit_price DESC;

--31. Use a CTE to identify the three highest-revenue months.

WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date                     AS month,
           SUM(quantity * unit_price * (1 - discount / 100))          AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT TO_CHAR(month, 'YYYY-MM') AS month,
       ROUND(revenue, 2)         AS revenue
FROM monthly
ORDER BY revenue DESC
LIMIT 3;

--32. Find customers purchasing from at least three categories.
SELECT c.customer_id, c.customer_name, c.customer_segment,
       COUNT(DISTINCT o.product_category)                        AS categories_bought,
       STRING_AGG(DISTINCT o.product_category, ', ')              AS categories
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.customer_segment
HAVING COUNT(DISTINCT o.product_category) >= 3
ORDER BY categories_bought DESC, c.customer_id;


--33. Use a CTE to calculate category revenue, cost, profit, and profit margin.
WITH category_totals AS (
    SELECT product_category,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue,
           SUM(quantity * cost_price)                        AS cost
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category
)
SELECT product_category,
       ROUND(revenue, 2)                                       AS revenue,
       ROUND(cost, 2)                                          AS cost,
       ROUND(revenue - cost, 2)                                AS profit,
       ROUND((revenue - cost) / NULLIF(revenue, 0) * 100, 2)   AS profit_margin_pct
FROM category_totals
ORDER BY profit DESC;

--34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
WITH today AS (
    SELECT MAX(order_date) AS today FROM orders
),
last_completed AS (
    SELECT customer_id, MAX(order_date) AS last_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment,
       lc.last_completed_order,
       t.today - lc.last_completed_order AS days_since_last_purchase
FROM last_completed lc
JOIN customers c ON c.customer_id = lc.customer_id
CROSS JOIN today t
WHERE t.today - lc.last_completed_order > 90
ORDER BY days_since_last_purchase DESC;

--35. Rank customers by spending using `RANK()`.
WITH today AS (
    SELECT MAX(order_date) AS today FROM orders
),
last_completed AS (
    SELECT customer_id, MAX(order_date) AS last_completed_order
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.city, c.customer_segment,
       lc.last_completed_order,
       t.today - lc.last_completed_order AS days_since_last_purchase
FROM last_completed lc
JOIN customers c ON c.customer_id = lc.customer_id
CROSS JOIN today t
WHERE t.today - lc.last_completed_order > 90
ORDER BY days_since_last_purchase DESC;

--36. Number each customer's orders by recency using `ROW_NUMBER()`.
SELECT customer_id, order_id, order_date, product_name, order_status,
       ROW_NUMBER() OVER (PARTITION BY customer_id
                          ORDER BY order_date DESC, order_id DESC) AS recency_number
FROM orders
ORDER BY customer_id, recency_number;

--37. Rank products within categories using `DENSE_RANK()`.

WITH product_revenue AS (
    SELECT product_category, product_name,
           SUM(quantity * unit_price * (1 - discount / 100)) AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY product_category, product_name
)
SELECT product_category, product_name,
       ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (PARTITION BY product_category ORDER BY revenue DESC) AS rank_in_category
FROM product_revenue
ORDER BY product_category, rank_in_category;

--38. Calculate cumulative monthly revenue.

WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date              AS month,
           SUM(quantity * unit_price * (1 - discount / 100))   AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT TO_CHAR(month, 'YYYY-MM')                     AS month,
       ROUND(revenue, 2)                             AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2)  AS cumulative_revenue
FROM monthly
ORDER BY month;

--39. Compare monthly revenue using `LAG()`.

WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date              AS month,
           SUM(quantity * unit_price * (1 - discount / 100))   AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
)
SELECT TO_CHAR(month, 'YYYY-MM')                                  AS month,
       ROUND(revenue, 2)                                          AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2)               AS previous_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2)     AS change_vs_previous
FROM monthly
ORDER BY month;

--40. Calculate month-over-month revenue growth (%).

WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date              AS month,
           SUM(quantity * unit_price * (1 - discount / 100))   AS revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY 1
),
with_prev AS (
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly
)
SELECT TO_CHAR(month, 'YYYY-MM')                                          AS month,
       ROUND(revenue, 2)                                                  AS revenue,
       ROUND(prev_revenue, 2)                                             AS previous_month_revenue,
       ROUND((revenue - prev_revenue) / NULLIF(prev_revenue, 0) * 100, 2) AS mom_growth_pct
FROM with_prev
ORDER BY month;

--41. Divide customers into four spending groups using `NTILE(4)`.

WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, c.customer_segment,
       ROUND(ct.total_spending, 2)                          AS total_spending,
       NTILE(4) OVER (ORDER BY ct.total_spending DESC)      AS spending_quartile
FROM customer_totals ct
JOIN customers c ON c.customer_id = ct.customer_id
ORDER BY spending_quartile, total_spending DESC;



-- Summary of the four groups (how much each quarter of customers is worth):
WITH customer_totals AS (
    SELECT customer_id,
           SUM(quantity * unit_price * (1 - discount / 100)) AS total_spending
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
quartiles AS (
    SELECT total_spending, NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_quartile
    FROM customer_totals
)
SELECT spending_quartile,
       COUNT(*)                                                        AS customers,
       ROUND(MIN(total_spending), 2)                                   AS min_spending,
       ROUND(MAX(total_spending), 2)                                   AS max_spending,
       ROUND(SUM(total_spending), 2)                                   AS group_revenue,
       ROUND(SUM(total_spending) / SUM(SUM(total_spending)) OVER () * 100, 2) AS share_of_revenue_pct
FROM quartiles
GROUP BY spending_quartile
ORDER BY spending_quartile;


--42. Calculate each category's share of total revenue using window functions.

SELECT product_category,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100)), 2)                     AS revenue,
       ROUND(SUM(SUM(quantity * unit_price * (1 - discount / 100))) OVER (), 2)        AS total_revenue,
       ROUND(SUM(quantity * unit_price * (1 - discount / 100))
             / SUM(SUM(quantity * unit_price * (1 - discount / 100))) OVER () * 100, 2) AS revenue_share_pct
FROM orders
WHERE order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue_share_pct DESC;


--43. Create a `monthly_sales_summary` view (month, orders, revenue, cost, profit). Then `SELECT` from it.

CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(*)                              AS orders,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100))
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS revenue,
       ROUND(COALESCE(SUM(quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS cost,
       ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100) - quantity * cost_price)
             FILTER (WHERE order_status = 'Completed'), 0), 2) AS profit
FROM orders
GROUP BY DATE_TRUNC('month', order_date);
 
SELECT TO_CHAR(month, 'YYYY-MM') AS month, orders, revenue, cost, profit
FROM monthly_sales_summary
ORDER BY month;

--44. Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. Show it working for one customer **and** for an ID that does not exist (it should return 0, not NULL).

CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_revenue NUMERIC;
BEGIN
    SELECT ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100)), 0), 2)
      INTO v_revenue
      FROM orders
     WHERE customer_id  = p_customer_id
       AND order_status = 'Completed';
 
    RETURN v_revenue;
END;
$$;
 
-- Working for a real customer:
SELECT 1 AS customer_id, customer_completed_revenue(1) AS completed_revenue;
-- Working for an ID that does not exist (returns 0, not NULL):
SELECT 9999 AS customer_id, customer_completed_revenue(9999) AS completed_revenue;
-- Bonus: the function used across every customer, cross-checked against Q24 (top 5):
SELECT customer_id, customer_name, customer_completed_revenue(customer_id) AS completed_revenue
FROM customers
ORDER BY completed_revenue DESC
LIMIT 5;

--45. Segment customers into High, Medium and Low Value  and explain why you chose your thresholds.

CREATE OR REPLACE FUNCTION customer_completed_revenue(p_customer_id INTEGER)
RETURNS NUMERIC
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_revenue NUMERIC;
BEGIN
    SELECT ROUND(COALESCE(SUM(quantity * unit_price * (1 - discount / 100)), 0), 2)
      INTO v_revenue
      FROM orders
     WHERE customer_id  = p_customer_id
       AND order_status = 'Completed';
 
    RETURN v_revenue;
END;
$$;
 
-- Working for a real customer:
SELECT 1 AS customer_id, customer_completed_revenue(1) AS completed_revenue;
-- Working for an ID that does not exist (returns 0, not NULL):
SELECT 9999 AS customer_id, customer_completed_revenue(9999) AS completed_revenue;
-- Bonus: the function used across every customer, cross-checked against Q24 (top 5):
SELECT customer_id, customer_name, customer_completed_revenue(customer_id) AS completed_revenue
FROM customers
ORDER BY completed_revenue DESC
LIMIT 5;

--46. Produce a management report: the top five customers, top five products, the most profitable category, and the lowest-revenue month.
WITH completed AS (
    SELECT o.*,
           o.quantity * o.unit_price * (1 - o.discount / 100) AS revenue,
           o.quantity * o.cost_price                          AS cost
    FROM orders o
    WHERE o.order_status = 'Completed'
),
top_customers AS (
    SELECT '1. Top 5 customers'::text AS section,
           ROW_NUMBER() OVER (ORDER BY SUM(cp.revenue) DESC) AS position,
           c.customer_name || ' (' || c.city || ', ' || c.customer_segment || ')' AS item,
           ROUND(SUM(cp.revenue), 2) AS revenue_ksh,
           NULL::numeric             AS profit_ksh
    FROM completed cp
    JOIN customers c ON c.customer_id = cp.customer_id
    GROUP BY c.customer_id, c.customer_name, c.city, c.customer_segment
    ORDER BY SUM(cp.revenue) DESC
    LIMIT 5
),
top_products AS (
    SELECT '2. Top 5 products',
           ROW_NUMBER() OVER (ORDER BY SUM(revenue) DESC),
           product_name || ' (' || product_category || ')',
           ROUND(SUM(revenue), 2),
           ROUND(SUM(revenue - cost), 2)
    FROM completed
    GROUP BY product_name, product_category
    ORDER BY SUM(revenue) DESC
    LIMIT 5
),
best_category AS (
    SELECT '3. Most profitable category',
           1::bigint,
           product_category || ' (margin ' ||
               ROUND(SUM(revenue - cost) / NULLIF(SUM(revenue), 0) * 100, 1) || '%)',
           ROUND(SUM(revenue), 2),
           ROUND(SUM(revenue - cost), 2)
    FROM completed
    GROUP BY product_category
    ORDER BY SUM(revenue - cost) DESC
    LIMIT 1
),
worst_month AS (
    SELECT '4. Lowest-revenue month',
           1::bigint,
           TO_CHAR(month, 'Mon YYYY') || ' (' || orders || ' orders placed)',
           revenue,
           profit
    FROM monthly_sales_summary
    ORDER BY revenue ASC
    LIMIT 1
)
SELECT * FROM top_customers
UNION ALL SELECT * FROM top_products
UNION ALL SELECT * FROM best_category
UNION ALL SELECT * FROM worst_month
ORDER BY section, position;
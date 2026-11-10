-- Q1: Retrieve all customer records
SELECT * from customers c ;

-- Q2: Display customer names, cities, and segments
SELECT customer_name , city, customer_segment 
from customers;


--3. Find customers living in Nairobi.
--4. Find customers registered after January 1, 2025.
--5. Display all unique customer cities.
--6. Retrieve the 10 most recent orders.
--7. Find orders with unit prices above KSh 10,000.
--8. Find customers whose names start with A.
--9. Retrieve orders with quantities between 2 and 5.
--10. Find orders paid through M-Pesa.
--11. Count all customers.
--12. Count all orders.
--13. Calculate completed-order revenue.
--14. Calculate the average completed-order value.
--15. Find the highest and lowest product prices.
--16. Calculate revenue by product category.
--17. Count customers by city.
--18. Calculate quantity sold by product.
--19. Find categories generating more than KSh 100,000 in revenue.
--20. Calculate the percentage of cancelled orders.
--21. Display orders with customer names and cities.
--22. Calculate total spending by customer.
--23. Identify customers who have never ordered.
--24. Find the 10 highest-spending customers.
--25. Calculate revenue by customer city.
--26. Identify customers with more than five orders.
--27. Calculate average customer spending by segment.
--28. Identify the most popular category among VIP customers.
--29. Find customers spending above the average total spending per purchasing customer.
--30. Find products priced above the overall average unit price.
--31. Use a CTE to identify the three highest-revenue months.
--32. Find customers purchasing from at least three categories.
--33. Use a CTE to calculate category revenue, cost, profit, and profit margin.
--34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.
--35. Rank customers by spending using `RANK()`.
--36. Number each customer's orders by recency using `ROW_NUMBER()`.
--37. Rank products within categories using `DENSE_RANK()`.
--38. Calculate cumulative monthly revenue.
--39. Compare monthly revenue using `LAG()`.
--40. Calculate month-over-month revenue growth (%).
--41. Divide customers into four spending groups using `NTILE(4)`.
--42. Calculate each category's share of total revenue using window functions.
--43. Create a `monthly_sales_summary` view (month, orders, revenue, cost, profit). Then `SELECT` from it.
--44. Create a PostgreSQL function that returns completed-order revenue for a supplied customer ID. Show it working for one customer **and** for an ID that does not exist (it should return 0, not NULL).
--45. Segment customers into High, Medium and Low Value  and explain why you chose your thresholds.
--46. Produce a management report: the top five customers, top five products, the most profitable category, and the lowest-revenue month.

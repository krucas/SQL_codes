SELECT COUNT(store) FROM public.orders;


SELECT c.customer_id, 
	COUNT(o.order_id) as orders_count
FROM orders as o
RIGHT JOIN customers as c
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY orders_count DESC;


SELECT c.customer_id,
	SUM(oi.quantity * oi.unit_price_czk ) as revenue
FROM customers as c
LEFT JOIN orders as o
ON c.customer_id = o.customer_id
JOIN order_items as oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY revenue 
LIMIT 5;


SELECT EXTRACT('month' FROM created_date) as month,
		COUNT(customer_id)
FROM customers
GROUP BY month
ORDER BY month ASC;

SELECT 
    DATE_TRUNC('month', created_date) AS month,
    COUNT(customer_id) AS customers
FROM customers
GROUP BY month
ORDER BY month;


ALTER TABLE order_items
ADD COLUMN price_category TEXT;

UPDATE order_items
SET price_category =
 
	CASE WHEN unit_price_czk < 2425 THEN 'nizka'
		WHEN unit_price_czk < 5400 THEN 'stredni'
		WHEN unit_price_czk < 9924 THEN 'prumerna'
		ELSE 'nadprumerna'
	END ; 

SELECT * FROM order_items;




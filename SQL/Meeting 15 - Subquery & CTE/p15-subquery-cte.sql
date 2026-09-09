-- 1. Subquery = query di dalam query
-- Tampilkan customer yang total_spent-nya lebih besar dari rata-rata seluruh customer.
SELECT * FROM customers
WHERE total_spent > (
	SELECT AVG(total_spent)
	FROM customers
)

-- 2. Subquery di WHERE
-- Tampilkan customer yang spending-nya lebih tinggi dari rata-rata customer.
SELECT
	name,
	city,
	total_spent
FROM customers
WHERE total_spent > (
	SELECT AVG(total_spent)
	FROM customers
)

-- 3. Subquery yang menghasilkan satu kolom
-- mencari customer yang pernah melakukan order
SELECT
	id,
	name
FROM customers
WHERE id IN (
	SELECT customer_id
	FROM orders
)

-- 4. Subquery di FROM
-- membuat subquery sebagai temporary result yang diperlakukan seperti tabel
SELECT *
FROM (
    SELECT
        name,
        city,
        total_spent
    FROM customers
    WHERE total_spent >= 3000000
) AS high_spenders;					-- Alias,wajib untuk derived table di PostgreSQL.

-- 5. CTE — Common Table Expression
-- Syntax dasarnya:

WITH nama_cte AS (
    SELECT ...
)
SELECT *
FROM nama_cte;
-----------------------
WITH high_spenders AS (
    SELECT
        name,
        city,
        total_spent
    FROM customers
    WHERE total_spent >= 3000000
)
SELECT *
FROM high_spenders;

-- 6. CTE bisa punya beberapa tahap
WITH high_spenders AS (
    SELECT *
    FROM customers
    WHERE total_spent >= 3000000
),
bandung_customers AS (
    SELECT *
    FROM high_spenders
    WHERE city = 'Bandung'
)
SELECT *
FROM bandung_customers;
--Alurnya:

--customers
--    ↓
--high_spenders
--    ↓
--bandung_customers
--    ↓
--final SELECT

-- 7. CTE + Aggregate
-- Cari customer yang spending-nya di atas rata-rata.
WITH average_spending AS (
    SELECT AVG(total_spent) AS avg_spending
    FROM customers
)
SELECT
    c.name,
    c.city,
    c.total_spent
FROM customers c
CROSS JOIN average_spending a
WHERE c.total_spent > a.avg_spending;


-- EXERCISE
-- Soal 1 — Subquery di WHERE
-- name | city | total_spent . untuk customer yang memiliki total_spent lebih besar dari rata-rata seluruh customer
SELECT
	name,
	city,
	total_spent
FROM customers
WHERE total_spent > (
	SELECT AVG(total_spent)
	FROM customers
)

-- Soal 2 — Subquery dengan MAX
-- name | city | total_spent
-- customer yang memiliki total_spent paling tinggi.
SELECT
	name,
	city,
	total_spent
FROM customers
WHERE total_spent = ( 
	SELECT MAX(total_spent)
	FROM customers
);

-- Soal 3 — Subquery dengan MIN
SELECT
	name,
	city,
	total_spent
FROM customers
WHERE total_spent = ( 
	SELECT MIN(total_spent)
	FROM customers
);

-- Soal 4 — Subquery IN
-- Tampilkan customer yang pernah melakukan order.
-- customer_id | name | city
SELECT
	customers.id,
	customers.name,
	customers.city
FROM customers
WHERE id IN (
	SELECT customer_id
	FROM orders
)

-- Soal 5 — Subquery NOT IN
-- Tampilkan customer yang belum pernah melakukan order
SELECT
	customers.id,
	customers.name,
	customers.city
FROM customers
WHERE id NOT IN (
	SELECT customer_id
	FROM orders
)

-- Soal 6 — Subquery + Aggregate
-- Cari total nilai seluruh order.
-- Kemudian tampilkan order yang memiliki total lebih besar dari rata-rata nilai order.
-- order_id | customer_id | total
SELECT
	orders.id AS order_id,
	customer_id,
	orders.total 
FROM orders
WHERE total > (
	SELECT AVG(total)
	FROM orders 
)

-- 	Soal 7 — Subquery di FROM
-- Buat subquery yang menghasilkan customer dengan:
-- name
-- city
-- total_spent
-- hanya untuk customer dengan total_spent >= 3000000
SELECT *
FROM (
	SELECT
		name,
		city,
		total_spent
	FROM customers
	WHERE total_spent > 3000000
)
AS orang_kaya

-- Soal 8 — Subquery + JOIN
-- Tampilkan customer yang memiliki minimal satu order dengan nilai total > 1.000.000.
-- customer_name | order_id | total
SELECT
	c.name AS  customer_name,
	o.order_id,
	o.total AS total 
FROM customers c
INNER JOIN(
	SELECT
		id AS order_id,
		customer_id,
		total
	FROM orders
	WHERE total > 1000000
) AS o ON c.id = o.customer_id; 

-- Soal 9 — CTE dasar
-- Gunakan CTE untuk membuat temporary result bernama:
--high_spenders - yang berisi customer dengan:
--total_spent >= 3000000
--Kemudian tampilkan:
--name | city | total_spent
WITH high_spender AS (
	SELECT
		name,
		city,
		total_spent
	FROM customers
	WHERE total_spent >= 3000000
) SELECT * FROM high_spender

-- Soal 10 — Multiple CTE
-- Buat CTE bernama:
-- customer_orders
-- yang menggabungkan:
-- customers
-- +
-- orders
-- dan menghasilkan minimal:
--customer_name
--order_id
--order_date
--total
-- CTE kedua
-- Gunakan CTE pertama untuk mencari customer yang memiliki total nilai order lebih besar dari 2.000.000.
-- Output akhirnya:
-- customer_name | total_order_value
WITH customers_orders  AS(
	SELECT
		c.name AS customer_name,
		o.id AS order_id,
		o.order_date,
		o.total
	FROM customers c
	INNER JOIN orders o ON c.id = o.customer_id
),
high_spender AS (
		customer_name,
	SELECT
		SUM(total) AS total_order_value
	FROM customers_orders
	GROUP BY customer_name
	HAVING SUM(total) > 2000000
) SELECT * FROM high_spender;
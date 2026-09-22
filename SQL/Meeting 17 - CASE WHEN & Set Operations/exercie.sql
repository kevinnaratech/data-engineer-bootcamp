-- Soal 1 — CASE WHEN
-- name
-- total_spent
-- spending_category
SELECT
	name,
	total_spent,
	CASE
		WHEN total_spent < 1000000 THEN 'Low'
		WHEN total_spent <= 5000000 THEN 'Medium'
		ELSE 'High'
	END AS spending_category
FROM customers

-- Soal 2 — CASE + ORDER BY

-- Tampilkan semua customer dengan:

-- name
-- total_spent
-- spending_category

-- Kemudian urutkan:

-- High
-- Medium
-- Low
SELECT
	name,
	total_spent,
	CASE
		WHEN total_spent > 5000000 THEN 'High'
		WHEN total_spent > 1000000 THEN 'Medium'
		ELSE 'Low'
	END AS spending_category
FROM customers
	ORDER BY
		CASE
			WHEN total_spent > 5000000 THEN 1
			WHEN total_spent > 1000000 THEN 2
			ELSE 3
		END;

-- Soal 3 — UNION
-- Tampilkan daftar name customer yang berasal dari:
-- Jakarta
-- Surabaya
SELECT
	name
FROM customers
WHERE city = 'Jakarta'

UNION

SELECT
	name
FROM customers
WHERE city = 'Surabaya'

-- Soal 4 — UNION ALL
-- Buat query yang menghasilkan daftar kota dari:
-- customer dengan total_spent > 2 juta
-- dan
-- customer dengan total_spent > 5 juta
SELECT
	city
FROM customers
WHERE total_spent > 2000000

UNION ALL

SELECT city
FROM customers
WHERE total_spent > 5000000

-- Soal 5 — INTERSECT
-- Cari name customer yang:
-- berasal dari Jakarta
-- dan
-- memiliki total_spent > 2.000.000
SELECT name
FROM customers
WHERE city = 'Jakarta'

INTERSECT

SELECT name
FROM customers
WHERE total_spent > 2000000

-- Soal 6 — CASE + Aggregate
-- spending_category | total_customer
SELECT
	CASE
		WHEN total_spent < 1000000 THEN 'Low'
		WHEN total_spent <= 5000000 THEN 'Medium'
		ELSE 'High'
	END AS category_spending,
	COUNT(*) AS total_customer
FROM customers
	GROUP BY
		CASE
		WHEN total_spent < 1000000 THEN 'Low'
		WHEN total_spent <= 5000000 THEN 'Medium'
		ELSE 'High'
	END;

-- Soal 7 — CASE pada orders

-- Tampilkan:

-- id
-- total
-- order_category
SELECT
	id,
	total,
	CASE
		WHEN total < 500000 THEN 'Small'
		WHEN total <= 2000000 THEN 'Medium'
		ELSE 'Large'
	END AS order_category
FROM orders

-- Soal 8 — CASE + SUM
-- Hitung total nilai order berdasarkan kategori:
-- Small
-- Medium
-- Large
-- Output:
-- order_category | total_revenue
SELECT
	CASE
		WHEN total < 500000 THEN 'Small'
		WHEN total < 2000000 THEN 'Medium'
		ELSE 'Large'
	END AS order_category,
	SUM(total) AS total_revenue
FROM orders
	GROUP BY
		CASE
		WHEN total < 500000 THEN 'Small'
		WHEN total < 2000000 THEN 'Medium'
		ELSE 'Large'
	END;

-- Soal 9 — UNION ALL + Label
-- Gabungkan customer dari:
-- Jakarta
-- dan:
-- Surabaya
-- dengan output:
-- name | source_city
SELECT
	name,
	city AS source_city
FROM customers
WHERE city = 'Jakarta' 

UNION ALL

SELECT
	name,
	city AS source_city
FROM customers
WHERE city = 'Surabaya'

-- Soal 10 — Mini Challenge
-- Cari customer yang berada di Jakarta atau Surabaya DAN memiliki total_spent >= 2.000.000.
-- Output:
-- name
-- city
-- total_spent
-- spending_category
-- spending_category:
-- >= 5 juta → 'High'
-- < 5 juta  → 'Medium'
SELECT
	name,
	city,
	total_spent,
	CASE
		WHEN total_spent < 5000000 THEN 'Medium'
		ELSE 'High'
	END AS spending_category
FROM customers
WHERE city IN ('Jakarta', 'Surabaya')
	AND total_spent >= 2000000


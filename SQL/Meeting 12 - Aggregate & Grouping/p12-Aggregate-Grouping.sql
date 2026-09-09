-- 1. Aggregate Functions
-- COUNT()
-- Menghitung jumlah data.
SELECT COUNT(*) FROM customers;

-- SUM()
-- Menghitung jumlah nilai.
SELECT SUM(total_spent) FROM customers;

-- AVG()
-- Menghitung rata-rata.
SELECT AVG(total_spent) FROM customers;

-- MIN() dan MAX()
-- Nilai terkecil
SELECT MIN(total_spent)
FROM customers;
-- Nilai terbesar
SELECT MAX(total_spent)
FROM customers;

-- 2. Bisa digabung
SELECT
	COUNT(*) AS total_costumers,
	SUM(total_spent) AS total_revenue,
	AVG(total_spent) AS average_spending,
	MIN(total_spent) AS minimum_spending,
    MAX(total_spent) AS maximum_spending
FROM customers;

-- 3. Masuk ke GROUP BY
SELECT
	city,
	SUM(total_spent) AS total_spent
FROM customers
GROUP BY city;
------------------------------------
SELECT
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city;
------------------------------------
SELECT
    city,
    MAX(total_spent) AS highest_spending
FROM customers
GROUP BY city;

-- 6. WHERE vs HAVING
-- Tampilkan kota yang total spending-nya lebih dari 5 juta.
SELECT 
	city,
	SUM(total_spent) AS total_spent
FROM customers
GROUP BY city
HAVING SUM(total_spent) > 5000000;

-- AGGREGATE + GROUPING
--SELECT
--	kolom_group
--	AGGREGATE_FUNCTION(KOLOM)
--FROM tabel
--WHERE kondisi_row
--GROUP BY kolom_group
--HAVING kondisi_group
--ORDER BY ...

---------------------------------
-- SOAL 1
-- Tampilkan jumlah seluruh customers
SELECT COUNT(*) FROM customers;

-- Soal 2
-- Tampilkan total seluruh total_spent dari semua customer.
SELECT SUM(total_spent) FROM customers;

-- Soal 3
-- Tampilkan rata-rata total_spent seluruh customer.
SELECT AVG(total_spent) FROM customers;

-- Soal 4
-- Tampilkan spending paling rendah dan paling tinggi dari seluruh customer.
SELECT
    MIN(total_spent) AS minimum_spent,
    MAX(total_spent) AS maximum_spent
FROM customers;

-- Soal 5
-- Tampilkan: city | total_customers
-- yang menunjukkan jumlah customer per kota.
SELECT
	city,
	COUNT(*) AS total_customers
FROM customers
GROUP BY city;

-- Soal 6
-- Tampilkan: city | total_spent
-- yang menunjukkan total spending per kota.
SELECT
	city,
	SUM(total_spent) AS total_spent
FROM customers
GROUP BY city;

-- Soal 7
-- Tampilkan rata-rata spending per kota.
SELECT
	city,
	AVG(total_spent) AS average_spent
FROM customers
GROUP BY city;

-- Soal 8
-- Tampilkan kota yang memiliki lebih dari 1 customer
SELECT
	city,
	COUNT(*) AS total_customers
FROM customers
GROUP BY city
HAVING COUNT(*)  > 1;

-- Soal 9
-- Tampilkan kota yang memiliki total spending lebih dari 3 juta.
SELECT
	city,
	SUM(total_spent) AS total_spent
FROM customers
GROUP BY city
HAVING SUM(total_spent) > 3000000;

-- Soal 10 
-- Tampilkan kota yang:
-- bukan Jakarta
-- memiliki minimal 2 customer
-- total spending-nya minimal 5 juta
-- Output:
-- city | total_customers | total_spent

SELECT
	city,
	COUNT(*) AS total_customers,
	SUM(total_spent) AS total_spent
FROM customers
WHERE city != 'Jakarta'
GROUP BY city
HAVING COUNT(*) >= 2 AND
SUM(total_spent) >= 5000000;

-- 1. Kenapa kita butuh JOIN?
-- Misalnya database kita punya: customers, orders
-- Masalahnya:
-- orders cuma punya customer_id, bukan nama customer.
-- Kalau kita ingin menghasilkan:

--customer_name	totaly
--Andi	500000
--Andi	300000
--Budi	750000

--kita harus menggabungkan customers dengan orders.
--itulah fungsi JOIN.

--====================================================================

-- 2. Primary Key & Foreign Key
-- Primary key: Kolom yang mengidentifikasi satu baris secara unik.
-- Contoh:
--customers
------------------
--id ← PRIMARY KEY
--name
--city

--id tidak boleh punya nilai yang sama untuk dua customer.

--Foreign Key

--Kolom yang merujuk ke Primary Key di tabel lain.

--orders
----------------
--id
--customer_id ← FOREIGN KEY
--total

--orders.customer_id merujuk ke:

--customers.id

--Relasinya:

--customers
--   │
--   │ id
--  ↓
--orders
--   customer_id

--Jadi ketika kita menulis:

--ON customers.id = orders.customer_id

--kita sedang mengatakan:

--"Hubungkan order dengan customer yang ID-nya sama."

-- 3. INNER JOIN
-- INNER JOIN hanya mengambil data yang punya pasangan di kedua tabel.
-- INNER JOIN = hanya data yang match di kedua tabel.
SELECT
    customers.name,
    orders.total
FROM customers
INNER JOIN orders
    ON customers.id = orders.customer_id;

-- 4. LEFT JOIN
SELECT
    customers.name,
    orders.total
FROM customers
LEFT JOIN orders
    ON customers.id = orders.customer_id;
-- LEFT JOIN mengatakan:
-- "Ambil SEMUA data dari tabel sebelah kiri, meskipun tidak punya pasangan."

--==========================================================================
-- INNER JOIN
-- Soal 1 - customer_name | order_total 
SELECT
	customers.name,
	orders.total
FROM customers
INNER JOIN orders
	on customers.id = orders.customer_id;

-- Soal 2 - customer_name | order_date | order_total
SELECT
	customers.name,
	order_date,
	orders.total
FROM customers
INNER JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 3 - customer_name | city | order_total
-- Hanya customer yang memiliki order.
SELECT 
	customers.name,
	customers.city,
	orders.total
FROM customers
INNER JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 4 - customer_id | customer_name | order_id
SELECT
	customers.id AS customer_id,
	customers.name AS customer_name,
	orders.id AS order_id
FROM customers
INNER JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 5 - order_id | customer_name | total
-- Tampilkan semua order beserta nama customer yang melakukan order.
SELECT
	orders.id,
	customers.name,
	orders.total
FROM customers
INNER JOIN orders
	ON customers.id = orders.customer_id;

-- LEFT JOIN
-- Soal 6 - customer_name | order_id | total
SELECT
	customers.name,
	orders.id,
	orders.total
FROM customers
LEFT JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 7 - customer_name | city | order_total
SELECT
	customers.name,
	customers.city,
	orders.total
FROM customers
LEFT JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 8 - customer_name | order_date
SELECT
	customers.name,
	order_date
FROM customers
LEFT JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 9 - customer_name | order_id | total
-- Tampilkan semua customer dan order mereka, kemudian urutkan berdasarkan customer_name.
SELECT
	customers.name,
	orders.id,
	orders.total
FROM customers
LEFT JOIN orders
	ON customers.id = orders.customer_id
ORDER BY customers.name;

-- Level 3
-- Soal 10 - Tampilkan customer yang belum pernah melakukan order.
SELECT
	customers.name
FROM customers
LEFT JOIN orders
	ON customers.id = orders.customer_id
WHERE orders.total IS NULL

-- Soal 11 - customer_name |city | order_id | total
-- Tampilkan semua customer dari Jakarta, beserta order mereka jika ada.
SELECT
	customers.name,
	customers.city,
	orders.id,
	orders.total
FROM customers
LEFT JOIN orders
	ON customers.id = orders.customer_id
WHERE city = 'Jakarta'

-- Soal 12 - order_id | customer_name | city | total
-- Urutkan berdasarkan total dari terbesar ke terkecil
SELECT
	orders.id AS order_id,
	customers.name AS customer_name,
	customers.city,
	orders.total
FROM customers
INNER JOIN orders
	ON customers.id = orders.customer_id
ORDER BY orders.total DESC;



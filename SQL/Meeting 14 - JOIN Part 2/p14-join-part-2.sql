-- 1. RIGHT JOIN
-- Semua data dari tabel kanan dipertahankan.
SELECT
    customers.name,
    orders.total
FROM customers
RIGHT JOIN orders
    ON customers.id = orders.customer_id;
--Kalau ada order yang tidak punya customer yang cocok,
--order tersebut tetap muncul dan kolom customer menjadi NULL.

-- 2. FULL OUTER JOIN
-- Semua data dari kedua tabel.

-- 3. SELF JOIN
-- Sebuah tabel di-join dengan dirinya sendiri.
employees
--------------------------------
id | name  | manager_id
--------------------------------
1  | Budi  | NULL
2  | Andi  | 1
3  | Citra | 1
4  | Deni  | 2

manager_id menunjuk ke id employee lain.

Berarti:

Budi
├── Andi
│   └── Deni
└── Citra

Kita ingin menghasilkan:

employee | manager
---------|--------
Andi     | Budi
Citra    | Budi
Deni     | Andi

Nah, tabel employees harus digunakan dua kali.

Makanya kita pakai alias:

SELECT
    e.name AS employee,
    m.name AS manager
FROM employees e
JOIN employees m
    ON e.manager_id = m.id;

Perhatikan:

employees e

artinya kita menganggap tabel ini sebagai employee.

Sedangkan:

employees m

kita anggap sebagai manager.

Jadi sebenarnya:

employees e
      ↓
   employee

employees m
      ↓
   manager

Padahal sumber datanya satu tabel yang sama.

-- 4. Multiple Table Join
--customers
--   |
--   | customer_id
--   ↓
--orders
--   |
--   | product_id
   ↓
--products

--Kita ingin:

--customer_name
--order_date
--product_name
--total
SELECT
    customers.name,
    orders.order_date,
    products.name,
    orders.total
FROM customers
JOIN orders
    ON customers.id = orders.customer_id
JOIN products
    ON orders.product_id = products.id;
--customers
--    ↓
--customer_id
--    ↓
--orders
--    ↓
--product_id
--    ↓
--products

-- Soal 1 - RIGHT JOIN
-- customer_name | order_id | total
SELECT
	customers.name AS customer_name,
	orders.id AS order_id,
	orders.total
FROM customers
RIGHT JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 2 — FULL OUTER JOIN
-- customer_name | order_id | total
SELECT
	customers.name AS customer_name,
	orders.id AS order_id,
	orders.total
FROM customers
FULL OUTER JOIN orders
	ON customers.id = orders.customer_id;

-- Soal 3 — SELF JOIN
-- Anggap tabel:
--employees
-------------------------
--id
--name
--manager_id

--Tampilkan:
--employee_name | manager_name
SELECT
	e.name AS employee_name,
	m.name AS manager_name
FROM employees e
JOIN employees m
	ON e.manager_id = m.id;
 
-- Soal 4 — Multiple JOIN
customers
---------
id
name

orders
---------
id
customer_id
product_id
total

products
---------
id
name
-- customer_name | product_name | total
SELECT
	customers.name AS customer_name,
	products.name AS product_name,
	orders.total AS order_total
FROM customers
JOIN orders
	ON customers.id = orders.customer_id
JOIN products 
	ON orders.product_id = products.id;

-- Soal 5 — Multiple JOIN + tanggal
-- customer_name | product_name | order_date | total
SELECT
	customers.name,
	products.name,
	orders.order_date,
	orders.total
FROM customers
JOIN orders
	ON customers.id = orders.customer_id
JOIN products
	ON orders.product_id = products.id;
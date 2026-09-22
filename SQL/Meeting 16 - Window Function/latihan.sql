-- Soal 1 - ROW_NUMBER
-- Berikan nomor urut berdasarkan total_spent terbesar ke terkecil.
SELECT
	name,
	total_spent,
	ROW_NUMBER() OVER(
		ORDER BY total_spent DESC
	) AS row_rum
FROM customers;

-- Soal 2 - RANK
-- Gunakan RANK() untuk membuat ranking customer berdasarkan total_spent terbesar.
SELECT
	name,
	total_spent,
	RANK() OVER(
		ORDER BY total_spent DESC
	) AS ranking
FROM customers;

-- Soal 3 - DENSE_RANK
-- Gunakan DENSE_RANK() berdasarkan total_spent terbesar
SELECT
	name,
	total_spent,
	DENSE_RANK() OVER(
		ORDER BY total_spent DESC
	) AS dense_ranking
FROM customers

-- Soal 4 - Bandingkan 3 fungsi
-- name
--total_spent
--row_num
--rank_num
--dense_rank_num
SELECT
	name,
	total_spent,
	ROW_NUMBER() OVER(ORDER BY total_spent DESC) AS row_rum,
	RANK() OVER(ORDER BY total_spent DESC) AS rank_rum,
	DENSE_RANK() OVER(ORDER BY total_spent DESC) AS dense_rank_rum
FROM customers;

-- Level 2 — PARTITION BY
-- Soal 5 - Buat ranking order untuk masing-masing customer berdasarkan total terbesar.
SELECT
	customer_id,
	id AS order_id,
	total,
	RANK() OVER(
		PARTITION BY customer_id
		ORDER BY total DESC
	) AS customer_rank
FROM orders;

-- Soal 6
-- customer_id
-- id AS order_id
-- order_date
-- total
-- order_number
-- Gunakan ROW_NUMBER().
-- Nomor urut harus dimulai dari 1 untuk setiap customer, berdasarkan order_date paling lama ke terbaru.
SELECT
	customer_id,
	id AS order_id,
	order_date,
	total,
	ROW_NUMBER() OVER(
		PARTITION BY customer_id
		ORDER BY order_date ASC
	) AS order_number
FROM orders;

-- Soal 7 
-- Gunakan ROW_NUMBER() untuk mencari order terbesar setiap customer.
SELECT 
	customer_id,
	order_id,
	total
FROM (
	SELECT	
		customer_id,
		id AS order_id,
		total,
		ROW_NUMBER() OVER(
		PARTITION BY customer_id
		ORDER BY total DESC
	) AS row_num	
 FROM orders
) AS order_rank
WHERE row_num = 1;

-- Soal 8
-- cari 2 order terbesar dari setiap customer.
SELECT
	customer_id,
	order_id,
	total
FROM(
	SELECT
		customer_id,
		id AS order_id,
		total,
		RANK() OVER(
			PARTITION BY customer_id
			ORDER BY total DESC
	) AS rank_num
FROM orders
) AS rank_order
WHERE rank_num <= 2;

-- 9. Transaksi sebelumnya
-- Gunakan LAG() untuk mengambil total order sebelumnya dari customer yang sama.
SELECT
	customer_id,
	id AS order_id,
	order_date,
	total,
	LAG(total) OVER(
		PARTITION BY customer_id
		ORDER BY order_date
	)
FROM orders;

-- 10. Transaksi berikutnya
-- Gunakan LEAD() untuk mengambil total order berikutnya dari customer yang sama.
SELECT 
	customer_id,
	id AS order_id,
	order_date,
	total,
	LEAD(total) OVER (
		PARTITION BY customer_id
		ORDER BY order_date
	)
FROM orders;

-- 11. Perubahan nilai order
-- difference: total - previous_total
SELECT
	customer_id,
	id AS order_id,
	order_date,
	total,
	LAG(total) OVER (
		PARTITION BY customer_id
		ORDER BY order_date
	) AS previous_total,
	total - LAG(total) OVER(
		PARTITION BY customer_id
		ORDER BY order_date
	) AS difference
FROM orders

-- 12. Perubahan persentase
-- hitung persentase perubahan order dibanding order sebelumnya.
SELECT
	customer_id,
	id AS order_id,
	order_date,
	total,
	LAG(total) OVER (
		PARTITION BY customer_id
		ORDER BY order_date
	) AS previous_total,
	
	(total - LAG(total) OVER (
		PARTITION BY customer_id
		ORDER BY order_date
	))/
	LAG(total) OVER (
		PARTITION BY customer_id
			ORDER BY order_date
	) * 100 AS percentage_change
FROM orders

-- 13. Ranking + Total costumer
-- customer_total = total seluruh order milik customer tersebut
-- customer_rank = ranking order customer berdasarkan total DESC
-- Tidak boleh menggunakan GROUP BY untuk menghilangkan detail order.
SELECT
	customer_id,
	id AS order_id,
	order_date,
	total,
	SUM(total) OVER (
		PARTITION BY customer_id
	) AS customer_total,
	RANK() OVER (
		PARTITION BY customer_id
		ORDER BY total DESC
	) AS customer_rank
FROM orders

-- 14. Order sebelumnya + Ranking
-- customer_rank → ranking order customer berdasarkan total DESC
-- previous_total → total order sebelumnya berdasarkan order_date
SELECT
	customer_id,
	id AS  order_id,
	order_date,
	total,
	LAG(total)OVER(
		PARTITION BY customer_id
		ORDER BY order_date
	) AS previous_total,
	RANK() OVER(
		PARTITION BY customer_id
		ORDER BY total DESC
	) AS customer_rank
FROM orders

-- 15. Analisis customer
--  customer_id
-- order_id
-- order_date
-- total
-- order_rank
-- previous_total
-- next_total
-- difference_from_previous
SELECT
	customer_id,
	id AS order_id,
	order_date,
	total,
	RANK()OVER(
		PARTITION BY customer_id
		ORDER BY total DESC
	) AS order_rank,

	LAG(total) OVER(
		PARTITION BY customer_id
		ORDER BY order_date
	) AS previous_total,

	LEAD(total) OVER(
		PARTITION BY customer_id
		ORDER BY order_date
	) AS next_order,

	total - LAG(total) OVER( 
		PARTITION BY customer_id
		ORDER BY order_date
	) AS difference_previous_total
FROM orders
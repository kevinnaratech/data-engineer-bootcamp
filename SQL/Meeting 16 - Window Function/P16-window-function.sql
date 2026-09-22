-- 1. GROUP BY vs Window Function
-- GROUP BY : Mengubah banyak baris menjadi lebih sedikt baris
-- SELECT
--    customer_id,
--    SUM(total)
--FROM orders
--GROUP BY customer_id;

--Hasil:
--customer_id	sum
-- 1	1500000
-- 2	1000000

--Detail order hilang.

-- Window Function : Tidak menghilangkan baris
SELECT
	id,
	customer_id,
	total,
	SUM(total) OVER(
		PARTITION BY customer_id
	) AS customer_total
FROM orders;
-- Melakukan kalkulasi berdasarkan kumpulan baris tertentu tanpa menggabungkan
-- baris tersebut menjadi satu baris

-- 2. ROW_NUMBER()
-- Digunakan untuk memberikan nomor urut unik pada tiap baris
SELECT
	id,
	customer_id,
	total,
	ROW_NUMBER() OVER(
		ORDER BY total DESC  -- menentukan urutan pemberian nomor.
	) AS row_num
FROM orders;

-- 4. PARTITION BY
-- Pisahkan data menjadi kelompok berdasarkan customer_id,
-- Lalu jalankan window function secara terpisah pada masing-masing kelompok
SELECT
	id,
	customer_id,
	total,
	ROW_NUMBER() OVER (
		PARTITION BY customer_id
		ORDER BY total DESC
	) AS  row_num
FROM orders;

-- 5. RANK() VS DENSE_RANK()
-- RANK()
-- 100 → 1
-- 100 → 1
-- 80  → 3
-- 70  → 4
-- karena dua data mendapatkan ranking 1, rangking berikutnya menjadi 3

-- DENSE_RANK()
-- 100 → 1
-- 100 → 1
-- 80  → 2
-- 70  → 3
-- tidak ada loncatan

-- ROW_NUMBER()
-- 100 → 1
-- 100 → 2
-- 80  → 3
-- 70  → 4
-- selalu unik
SELECT
	name,
	total_spent,
	ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS row_number,
	RANK() OVER (ORDER BY total_spent DESC) AS rank,
	DENSE_RANK() OVER (ORDER BY total_spent DESC) AS dense_rank
FROM customers;

-- 7. LAG() dan LEAD()
-- -- kita mau melihat: total transaksi sekarang dibanding sebelum nya
LAG(total) OVER (		-- LAG ambil nilai sebelum nya
	ORDER BY order_date
)
-------------------------------------------------------------------
LEAD(total) OVER (		-- LEAD ambil nilai berikutnya	
	ORDER BY order_date
)
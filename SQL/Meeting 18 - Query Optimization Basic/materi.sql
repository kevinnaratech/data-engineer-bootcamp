-- 1. Index?
-- Struktur data tambahan yang dibuat database untuk mempercepat pencarian data berdasarkan kolom trterntu

-- 2. Contoh membuat index
-- Misalnya:

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

-- Sekarang database punya index untuk:
-- orders.customer_id
-- Jadi query seperti:
SELECT *
FROM orders
WHERE customer_id = 100;

-- bisa mendapatkan keuntungan dari index tersebut.
-- Perhatikan kata bisa.
-- Index bukan berarti:
-- "Setiap query pasti otomatis lebih cepat."
-- Database punya query planner yang menentukan strategi eksekusi.

-- 4. Index jangan asal bikin
-- Jangan berpikir:
-- "Semua kolom gue kasih index aja biar cepat."
-- Salah.
-- Index punya cost.
-- Karena ketika:
INSERT
UPDATE
DELETE
-- terjadi, database juga perlu menjaga index tetap konsisten.
-- Jadi:
-- lebih banyak index
--        ↓
-- SELECT tertentu bisa lebih cepat
--        ↓
-- tetapi
--        ↓
-- INSERT/UPDATE/DELETE bisa lebih mahal
--        +
--        ↓
-- storage tambahan

-- Jadi index harus dibuat berdasarkan pola query yang memang sering digunakan.

-- 5. EXPLAIN
-- Kita bisa bertanya kepada PostgreSQL:
-- "query ini sebenarnya mau dijalankan dengan cara apa?"
-- Gunakan:
EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 100;
-- PostgreSQL akan memberikan execution plan.
-- Contohnya bisa terlihat seperti:
-- Seq Scan on orders
--   Filter: (customer_id = 100)
  
-- 6. Apa itu Sequential Scan?
-- Seq Scan

-- artinya PostgreSQL membaca tabel secara berurutan.

-- Secara sederhana:

-- row 1
--  ↓
-- row 2
--  ↓
-- row 3
--  ↓
-- row 4
--  ↓
-- ...

-- Ini tidak selalu buruk.

-- Ini poin yang harus di pegang.

-- Kalau tabel cuma punya 50 row:

-- 50 row

-- mungkin sequential scan justru lebih masuk akal daripada menggunakan index.

-- Jadi:

-- Seq Scan ≠ query buruk.

-- Yang penting adalah apakah execution plan tersebut masuk akal terhadap ukuran data dan kondisi query.

-- 7. EXPLAIN ANALYZE

-- Nah ini lebih powerful.

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 100;

-- Bedanya:

-- EXPLAIN

-- Memberikan rencana eksekusi.

-- EXPLAIN ANALYZE

-- Benar-benar menjalankan query lalu memberikan informasi aktual mengenai eksekusinya.

-- Misalnya bisa menemukan informasi seperti:

-- actual time=...
-- rows=...
-- loops=...

-- Ini berguna ketika kita ingin membandingkan:

-- estimated
-- vs
-- actual

-- 8. Contoh workflow optimization

-- Misalnya query:

SELECT *
FROM orders
WHERE customer_id = 100;
-- Step 1

-- Cek execution plan:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 100;
-- Step 2

-- Kalau memang relevan, buat index:

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);
-- Step 3

-- Cek lagi:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 100;
-- Step 4

-- Untuk pengukuran aktual:

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 100;

-- Jadi workflow dasarnya:

-- Query
--   ↓
-- EXPLAIN
--   ↓
-- Pahami execution plan
--   ↓
-- Identifikasi bottleneck
--   ↓
-- Optimasi
--   ↓
-- EXPLAIN ANALYZE
--   ↓
-- Bandingkan hasil

-- 1.
SELECT * FROM orders
WHERE customer_id = 5;

EXPLAIN
SELECT * FROM orders
WHERE customer_id = 5;

-- 2.
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5;

-- 3.
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5;

-- 4. 
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE order_date >= '2026-01-01';

-- Meeting 18 — Query Optimization Basic

-- 1. Apa itu Query Optimization?

-- Query optimization adalah proses memahami dan memperbaiki cara database menjalankan query agar penggunaan resource dan waktu eksekusinya lebih efisien.

-- Tujuannya bukan sekadar membuat query jalan, tetapi membuat query efisien, terutama ketika jumlah data semakin besar.

-- 2. Index

-- Index adalah struktur data tambahan yang membantu database menemukan data tertentu dengan lebih cepat.

-- Analogi:

-- Tanpa index:
-- Cari data → cek row satu per satu

-- Dengan index:
-- Cari data → gunakan index → langsung menuju data yang relevan

-- Contoh:

CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

-- Index di atas dibuat pada:

-- orders.customer_id

-- Sehingga query seperti:

SELECT *
FROM orders
WHERE customer_id = 5;

-- berpotensi menjadi lebih cepat pada dataset besar.

-- 3. Kapan Index Berguna?

-- Index tidak otomatis diperlukan hanya karena ada WHERE.

-- Index lebih berpotensi berguna ketika:

-- tabel berukuran besar
-- kolom sering digunakan untuk pencarian/filter
-- query hanya mengambil sebagian kecil data
-- kolom sering digunakan dalam JOIN
-- query tersebut sering dijalankan

-- Contoh:

-- 10.000.000 rows
--         ↓
-- WHERE customer_id = 123
--         ↓
-- hanya 100 rows yang dicari

-- Index pada customer_id bisa sangat membantu.

-- 4. Kapan Index Belum Tentu Berguna?

-- Kalau tabel kecil:

-- 3 rows

-- database bisa memilih Seq Scan karena membaca 3 row secara langsung lebih sederhana dan murah.

-- Index juga belum tentu membantu jika query mengambil hampir seluruh tabel.

-- Contoh:

-- 10.000.000 rows
--         ↓
-- query mengambil 9.500.000 rows

-- Dalam kondisi seperti ini, PostgreSQL bisa tetap memilih Seq Scan.

-- 5. Seq Scan

-- Sequential Scan (Seq Scan) berarti PostgreSQL membaca tabel secara berurutan untuk mencari data yang sesuai.

-- Contoh:

-- row 1 → cek
-- row 2 → cek
-- row 3 → cek
-- ...
-- row terakhir → cek

-- Seq Scan bukan berarti query buruk.

-- Untuk tabel kecil atau query yang mengambil sebagian besar data, Seq Scan bisa menjadi pilihan yang efisien.

-- 6. EXPLAIN

-- EXPLAIN digunakan untuk melihat execution plan yang dipilih PostgreSQL.

-- Contoh:

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5;

-- Contoh hasil:

-- Seq Scan on orders

-- Artinya PostgreSQL berencana menggunakan Sequential Scan.

-- 7. EXPLAIN ANALYZE

-- EXPLAIN ANALYZE menjalankan query secara nyata dan memberikan informasi aktual mengenai proses eksekusinya.

-- Contoh:

EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5;

-- Informasi penting yang bisa diperhatikan:

-- actual time
-- rows
-- loops
-- Execution Time
-- Perbedaan:
-- EXPLAIN
-- → melihat rencana eksekusi

-- EXPLAIN ANALYZE
-- → menjalankan query + melihat hasil aktual
-- 8. Cost

-- Contoh:

-- cost=0.00..28.12

-- cost adalah estimasi biaya relatif yang digunakan PostgreSQL untuk membandingkan execution plan.

-- Cost bukan waktu dalam milidetik.

-- Untuk waktu aktual, lihat:

-- Execution Time
-- 9. Query Planner

-- PostgreSQL mempunyai query planner yang menentukan cara menjalankan query.

-- Secara sederhana:

-- Query
--   ↓
-- Query Planner
--   ↓
-- Membandingkan execution plan
--   ↓
-- Memilih plan yang dianggap paling efisien

-- Misalnya PostgreSQL bisa mempertimbangkan:

-- Seq Scan
-- Index Scan
-- dan strategi lainnya

-- Kita tidak memaksa PostgreSQL menggunakan index hanya karena index tersedia.

-- 10. Workflow Query Optimization

-- Workflow dasar yang perlu diingat:

-- 1. Tulis query
--        ↓
-- 2. EXPLAIN
--        ↓
-- 3. Baca execution plan
--        ↓
-- 4. Identifikasi bottleneck
--        ↓
-- 5. Pertimbangkan optimasi
--        ↓
-- 6. EXPLAIN ANALYZE
--        ↓
-- 7. Bandingkan hasil

-- Jangan langsung berpikir:

-- Query lambat
-- ↓
-- CREATE INDEX

-- Lebih baik:

-- Query lambat
-- ↓
-- Cari tahu penyebabnya
-- ↓
-- EXPLAIN / EXPLAIN ANALYZE
-- ↓
-- Tentukan optimasi
-- ↓
-- Ukur kembali
-- 11. Prinsip Paling Penting
-- Jangan berpikir:

-- Data besar = wajib menggunakan index.

-- Yang benar:

-- Data besar membuat index semakin berpotensi berguna, tetapi PostgreSQL tetap menentukan execution plan berdasarkan kondisi query dan data.

-- Jadi mindset seorang developer/data engineer:

-- Query
-- ↓
-- Execution Plan
-- ↓
-- Performance
-- ↓
-- Optimization
-- ↓
-- Measure Again
-- 12. Kesimpulan

-- Index
-- → alat bantu untuk mempercepat pencarian data.

-- Seq Scan
-- → membaca tabel secara berurutan.

-- EXPLAIN
-- → melihat rencana PostgreSQL.

-- EXPLAIN ANALYZE
-- → menjalankan query dan melihat performa aktual.

-- Query Planner
-- → memilih execution plan yang dianggap paling efisien.

-- Index bukan selalu lebih cepat.
-- Database harus melihat ukuran tabel, jumlah data yang dicari, pola query, dan kondisi lainnya.

-- Optimization bukan menebak apa yang cepat. Optimization adalah mengukur, memahami execution plan, melakukan perubahan, lalu mengukur kembali.

-- Cheat Sheet
-- -- Membuat index
CREATE INDEX idx_orders_customer_id
ON orders(customer_id);

-- -- Melihat execution plan
EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5;

-- -- Melihat execution plan + performa aktual
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 5;
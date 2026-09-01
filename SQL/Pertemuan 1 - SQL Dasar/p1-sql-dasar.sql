-- 1. Select
-- Mengambil nama costumer
SELECT name FROM customers;

-- Mengambil nama dan kota
SELECT name, city FROM customers;

-- Menampilkan seluruh isi tabel
SELECT * FROM customers;

-- 2. Where
-- Cari customer yang tinggal di Jakarta
SELECT * FROM  customers
WHERE city = 'Jakarta'

-- Ambil customer yang minimal umur 25
SELECT * FROM customers
WHERE age >= 25;

-- 3. AND
-- Kedua kondisi harus benar -- 
-- Customer dijakarta yang umurnya minimal 21
SELECT * FROM customers
WHERE city = 'Jakarta'
AND age >= 21

-- 4. OR
-- Salah satu kondisi cukup terpenuhi
-- Customers dari Jakarta atau Bandung
SELECT * FROM customers
WHERE city = 'Jakarta'
OR city ='Bandung'

WHERE (city = 'Jakarta' OR city = 'Bandung')
  AND age >= 21;

-- 5. DISTINCT
-- Kalau ingin mengetahui kota unik
SELECT DISTINCT city
FROM customers;

-- 6. ORDER BY
-- Umur kecil -> besar
SELECT name, age
FROM customers
ORDER BY age ASC;

-- Umur besar -> kecil
SELECT name, age
FROM customers
ORDER BY age DESC;

-- Customer dengan pengeluaran terbesar
SELECT name, total_spent
FROM customers
ORDER BY total_spent DESC;

-- 8. LIMIT
-- 3 costumers dengan pengeluaran terbesar
SELECT name, total_spent
FROM customers
ORDER BY total_spent DESC
LIMIT 3;

-- Latihan 1
-- Tampilkan hanya name dan city semua customer
SELECT name, city
FROM customers;

-- Latihan 2
-- Cari semua costumer yang berasal dari bandung
SELECT name, city FROM customers 
WHERE city = 'Bandung'

-- Latihan 3
-- Cari customer yang umurnya lebih dari 25 tahun
SELECT name, age FROM customers
WHERE age > 25;

-- Latihan 4
-- Cari customer Jakarta yang umurnya minimal 21 tahun
SELECT * FROM customers
WHERE city = 'Jakarta'
AND age >= 21;

-- Latihan 5
-- Tampilkan semua kota yang unik
-- Petunjuk: Kita tidak mau kota yang duplikat.
SELECT DISTINCT city
FROM customers;

-- Latihan 6 
-- Tampilkan name dan total_spent, urutkan dari pengeluaran terbesar ke terkecil.
SELECT name, total_spent FROM customers
ORDER BY total_spent DESC;

-- Latihan 7
-- Tampilkan 2 customer dengan total_spent terbesar
SELECT name, total_spent FROM customers
ORDER BY total_spent DESC
LIMIT 2;

-- Latihan 8
-- Tampilkan name, city, dan total_spent 
-- untuk customer yang bukan dari Jakarta.
SELECT  name, city, total_spent FROM customers
WHERE city != 'Jakarta'

-- Latihan 9
-- Tampilkan customer yang berasal dari Jakarta atau Surabaya, 
-- dan memiliki total_spent minimal 2 juta.
SELECT * FROM customers
WHERE (city = 'Jakarta' OR city = 'Surabaya')
AND total_spent >= 2000000;

-- Latihan 10
-- Tampilkan 3 customer termuda yang 
-- total_spent-nya lebih dari 1 juta, mulai dari yang paling muda.
SELECT * FROM customers
WHERE total_spent > 1000000
ORDER BY age ASC
LIMIT 3;
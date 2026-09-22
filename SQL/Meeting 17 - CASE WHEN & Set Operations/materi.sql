-- 1. CASE WHEN
-- Anggap case when sebagai if/else is / else versi sql
SELECT
	name,
	total_spent,
	CASE
		WHEN total_spent < 1000000 THEN 'Bronze'
		WHEN total_spent < 5000000 THEN 'Silver'
		ELSE 'GOLD'
	END AS customer_level
FROM customers;

-- 2 CASE WHEN bukan cuma SELECT
-- ORDER BY
ORDER BY
    CASE
        WHEN total_spent > 5000000 THEN 1
        WHEN total_spent > 1000000 THEN 2
        ELSE 3
    END;
-- aggregate
SELECT
    COUNT(
        CASE
            WHEN total_spent > 5000000 THEN 1
        END
    ) AS vip_count
FROM customers;

-- 3. Set Operation
-- UNION: Menggabungkan baris dari dua hasil query.
SELECT city
FROM customers
WHERE city = 'Jakarta'

UNION

SELECT city
FROM customers
WHERE city = 'Surabaya'

-- 4. UNION ALL
-- Mempertahankan semua duplicate

-- 5. Syarat UNION
-- Jumlah kolom harus sama
-- tipe datanya juga harus kompatibel.
-- Kolom pertama:
-- customers.id
-- orders.id

--harus kompatibel.

-- Kolom kedua:

-- customers.name
-- orders.total
-- bermasalah kalau satu text, satunya numeric.

-- 6. INTERSECT: Cari yang sama
-- Query A:

-- Jakarta
-- Surabaya
-- Bandung

-- Query B:

-- Surabaya
-- Bandung
-- Medan

-- Maka:

-- Query A
-- INTERSECT
-- Query B

-- hasil:

-- Surabaya
-- Bandung

-- 7. Operation		Artinya
--    UNION			A + B, duplicate dihapus
--    UNION ALL		A + B, duplicate dipertahankan
--    INTERSECT		Yang ada di A DAN B
--    EXCEPT		Ada di A tapi tidak di B

-- Visual:

-- A = {1, 2, 3}
-- B = {3, 4, 5}

-- UNION
-- → {1, 2, 3, 4, 5}

-- INTERSECT
-- → {3}

-- EXCEPT
-- → {1, 2}

-- 8. Kapan UNION berguna?

-- Kapan UNION berguna?

-- Misalnya kita punya dua tabel:

-- customers_2025
-- customers_2026

-- Strukturnya sama:

-- id | name | city

-- Kita ingin menggabungkan datanya:

-- SELECT id, name, city
-- FROM customers_2025

-- UNION ALL

-- SELECT id, name, city
-- FROM customers_2026;

-- Ini jauh lebih masuk akal.

-- Dan untuk data pipeline, pola seperti ini cukup umum:

-- source_2025 ──┐
--               ├── UNION ALL ──→ dataset gabungan
-- source_2026 ──┘

-- 9. Pola CASE + Aggregate
SELECT
    CASE
        WHEN total_spent < 1000000 THEN 'Bronze'
        WHEN total_spent <= 5000000 THEN 'Silver'
        ELSE 'Gold'
    END AS customer_level,
    COUNT(*) AS total_customer
FROM customers
GROUP BY
    CASE
        WHEN total_spent < 1000000 THEN 'Bronze'
        WHEN total_spent <= 5000000 THEN 'Silver'
        ELSE 'Gold'
    END;
-- 1 — Design Dimension
CREATE TABLE dim_customer (
	customer_sk SERIAL PRIMARY KEY,
	customer_id VARCHAR(10),
	customer_name VARCHAR(60),
	city VARCHAR(60),
	valid_from DATE NOT NULL,
	valid_to DATE,
	is_current BOOLEAN NOT NULL
);

-- 2 — Initial Load 
INSERT INTO dim_customer (
	customer_id,
	customer_name,
	city,
	valid_from,
	valid_to,
	is_current
) VALUES (
	'C001',
	'Budi',
	'Jakarta',
	'2026-01-01',
	NULL,
	true
), (
	'C002',
	'Andi',
	'Surabaya',
	'2026-02-02',
	NULL,
	true
), (
	'C003',
	'Sinta',
	'Bandung',
	'2026-01-02',
	NULL,
	true
);

-- 3 — Detect Change 
UPDATE dim_customer
SET
	valid_to = '2026-03-14',
	is_current =  FALSE
WHERE customer_id = 'C001'
	AND is_current = TRUE;
	
INSERT INTO dim_customer (
	customer_id,
	customer_name,
	city,
	valid_from,
	valid_to,
	is_current
) VALUES (
	'C001',
	'Budi',
	'Bandung',
	'2026-03-15',
	NULL,
	TRUE
)

-- 4. Pada 2026-07-10:
-- C001: Bandung → Surabaya
UPDATE dim_customer
SET
	valid_to = '2026-07-9',
	is_current = FALSE
WHERE customer_id = 'C001'
	AND is_current = TRUE;

INSERT INTO dim_customer (
	customer_id,
	customer_name,
	city,
	valid_from,
	valid_to,
	is_current
) VALUES (
	'C001',
	'Budi',
	'Surabaya',
	'2026-07-10',
	NULL,
	TRUE
);

-- 5. Buat query untuk mengambil current customer.
SELECT *
FROM dim_customer
WHERE is_current = TRUE;

-- 6. Buat query untuk melihat seluruh history C001 berdasarkan waktu.
SELECT 
	customer_id,
    customer_name,
    city,
    valid_from,
    valid_to,
    is_current
FROM dim_customer
WHERE customer_id = 'C001'
ORDER BY valid_to ASC;

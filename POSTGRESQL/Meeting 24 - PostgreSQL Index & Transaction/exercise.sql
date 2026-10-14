-- Easy — Membuat index sederhana
-- Buat index pada finance_transactions.account_id. Jelaskan query apa yang berpotensi terbantu dan apa trade-off-nya.
CREATE INDEX idx_finance_transactions_account_id
ON transactions (account_id);
-- Index pada transactions.account_id berpotensi mempercepat query yang sering melakukan pencarian atau filtering berdasarkan account_id, 
-- misalnya mengambil seluruh transaksi milik suatu account. Tanpa index, PostgreSQL mungkin perlu melakukan sequential scan terhadap banyak row. 
-- Dengan index, PostgreSQL memiliki struktur pencarian tambahan yang dapat digunakan untuk menemukan row yang relevan dengan lebih efisien. 
-- Trade-off-nya adalah index membutuhkan storage tambahan dan harus diperbarui setiap kali terjadi INSERT, UPDATE, atau DELETE pada kolom yang terindeks, 
-- sehingga operasi write dapat menjadi lebih mahal.

-- Easy — Menguji rollback
-- Kurangi saldo Account A sebesar 50.000 di dalam transaction, lihat perubahan dalam sesi yang sama, lalu rollback. Pastikan saldo akhir tidak berubah.
SELECT * FROM accounts
WHERE id = '859b3172-0fc8-4798-8a1b-b77198fc900e';

BEGIN ;

UPDATE accounts
SET balance = balance - 50000
WHERE id = '859b3172-0fc8-4798-8a1b-b77198fc900e';

ROLLBACK;


-- Medium — Composite index
-- Buat index untuk tampilkan semua transaksi milik account tertentu, khusus transaksi expense. 
CREATE INDEX idx_transaction_account_created 
ON transactions (account_id, transaction_type)
-- account_id ditempatkan sebagai kolom pertama karena query terlebih dahulu membatasi transaksi berdasarkan account. 
-- transaction_type menjadi kolom kedua untuk mempersempit hasil berdasarkan jenis transaksi. Trade-off-nya adalah tambahan storage dan overhead pada operasi write karena index harus dipelihara.

-- Hard - Validasi transfer
BEGIN;

-- 1. Lock dan cek saldo kedua account
SELECT id, balance
FROM accounts
WHERE id IN (
    'ae53b055-f829-4724-a873-dc6890667667',
    '859b3172-0fc8-4798-8a1b-b77198fc900e'
)
FOR UPDATE;

-- 2. Debit Account A
UPDATE accounts
SET balance = balance - 12500
WHERE id = 'ae53b055-f829-4724-a873-dc6890667667'
  AND balance >= 12500;

-- 3. Credit Account B
UPDATE accounts
SET balance = balance + 12500
WHERE id = '859b3172-0fc8-4798-a1b-b77198fc900e';

-- 4. Jika semua valid dan berhasil
COMMIT;

-- Mini Project — Finance Transaction Engine
CREATE TABLE transfer_logs(
	transfer_id SERIAL PRIMARY KEY,
	from_account_id UUID NOT NULL,
	to_account_id UUID NOT NULL,
	amount NUMERIC(15,2),
	status VARCHAR(20) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 		
);

CREATE INDEX idx_transfer_logs_from_account
ON transfer_logs (from_account_id);

CREATE INDEX idx_transfer_logs_to_account
ON transfer_logs (to_account_id);

BEGIN;

-- Lock Account
SELECT id, balance
FROM accounts
WHERE id IN (
	'ae53b055-f829-4724-a873-dc6890667667',
	'859b3172-0fc8-4798-8a1b-b77198fc900e'
)
FOR UPDATE;

-- Debit A
UPDATE accounts
SET balance = balance - 12500
WHERE id = 'ae53b055-f829-4724-a873-dc6890667667'
  AND balance >= 12500;

-- Credit B
UPDATE accounts
SET balance = balance + 12500
WHERE id = '859b3172-0fc8-4798-8a1b-b77198fc900e';

-- Insert transfer_logs
INSERT INTO transfer_logs (
	from_account_id,
	to_account_id,
	amount,
	status
) VALUES (
	'ae53b055-f829-4724-a873-dc6890667667',
    '859b3172-0fc8-4798-8a1b-b77198fc900e',
    12500,
    'SUCCESS'
);

-- Cek log
SELECT *
FROM transfer_logs
ORDER BY transfer_id DESC
LIMIT 1;

COMMIT;
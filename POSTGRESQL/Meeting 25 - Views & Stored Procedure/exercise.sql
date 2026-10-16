-- 1. Easy — View
-- Buat View bernama expense_transactions.
CREATE VIEW expense_transaction AS
SELECT
	transaction_id,
	account_id,
	category_id,
	amount,
	description
FROM transactions
WHERE transaction_type = 'expense';

-- 2 Easy — View Query
-- Gunakan expense_transactions untuk mencari: Total seluruh pengeluaran.
SELECT SUM(amount) AS total_expense
FROM expense_transaction;

-- 3. Medium — Aggregation View
-- Buat View bernama account_expense_summary.
CREATE VIEW account_expense_summary AS
SELECT
	account_id,
	SUM(amount) AS total_expense,
	COUNT(*) AS transaction_count,
	AVG(amount) AS average_expense
FROM transactions
WHERE transaction_type = 'expense'
GROUP BY account_id;

-- 4. Medium — Materialized View
-- Buat Materialized View bernama: account_expense_summary_mv
CREATE MATERIALIZED VIEW account_expense_summary_mv AS
SELECT
	account_id,
	SUM(amount) AS total_expense,
	COUNT(*) AS transaction_count,
	AVG(amount) AS average_expense
FROM transactions
WHERE transaction_type = 'expense'
GROUP BY account_id;


-- 5. Hard — Function
-- Buat function: get_total_expense(account_id)
CREATE OR REPLACE FUNCTION
	get_total_expense(p_account_id UUID)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
	SELECT COALESCE(SUM(amount), 0)
	FROM transactions
	WHERE account_id = p_account_id
		AND transaction_type = 'expense';
$$;

-- 6. Hard — Function
-- Buat function: get_net_cashflow(account_id)
-- Logic: total income - total expense

CREATE OR REPLACE FUNCTION
	get_net_cashflow(p_account_id UUID)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
	SELECT 
		COALESCE(SUM(amount), 0) - 
		get_total_expense(p_account_id)
	FROM transactions
	WHERE account_id = p_account_id
		AND transaction_type = 'income';
$$;

-- 8. Hard — Procedure
-- Buat tabel: finance_audit_log
-- Minimal memiliki:
-- id
-- event_message
-- created_at
-- Kemudian buat procedure: log_finance_event(message)
CREATE TABLE finance_audit_log (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	event_message TEXT NOT NULL,
	creted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE
	log_finance_event(p_message TEXT)
LANGUAGE SQL
AS $$
	INSERT INTO finance_audit_log(event_message)
	VALUES (p_message);
$$;

-- Panggil procedure
CALL log_finance_event (
	'Testing'
)
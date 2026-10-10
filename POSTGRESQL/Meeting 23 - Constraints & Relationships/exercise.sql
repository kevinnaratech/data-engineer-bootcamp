
-- Persiapan 1: table users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(60) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    birth_date DATE,
    is_active BOOLEAN,
    interests TEXT[],
    metadata JSONB
);

-- Persiapan 2: table accounts
-- id UUID otomatis di-generate, jadi tidak perlu diisi manual
-- dan tipenya cocok dengan transactions.account_id (UUID)
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(60),
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0 CHECK (balance >= 0)
);

-- 1. Buat table categories
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(60) NOT NULL UNIQUE
);

-- 2. Buat table transactions
CREATE TABLE transactions (
    transaction_id   SERIAL PRIMARY KEY,
    account_id       UUID NOT NULL REFERENCES accounts(id),
    category_id      INT NOT NULL REFERENCES categories(category_id),
    amount           DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    transaction_type VARCHAR(20) NOT NULL
                     CHECK (transaction_type IN ('income', 'expense')),
    description      VARCHAR(255)
);

-- 3.1 Insert user (id UUID di-generate otomatis)
INSERT INTO users (
    id,
    name,
    email,
    birth_date,
    is_active,
    interests,
    metadata
)
VALUES (
    'Joko',
    'joko@mock.com',
    '2005-02-09',
    true,
    ARRAY['gaming', 'cooking'],
    '{"device": "android", "app_version": "1.0"}'
);

-- 3.2 Insert 2 account untuk user Joko
-- id tidak diisi manual, PostgreSQL yang generate
INSERT INTO accounts (user_id, name, balance)
VALUES
    ((SELECT id FROM users WHERE email = 'joko@mock.com'), 'BCA',  1000000),
    ((SELECT id FROM users WHERE email = 'joko@mock.com'), 'Cash', 500000);

-- 3.3 Insert 3 category (category_id di-generate otomatis)
INSERT INTO categories (name)
VALUES
    ('Food'),
    ('Salary'),
    ('Transport');

-- 3.4 Insert 3 transaction (1 income, 2 expense, account berbeda)
-- id account dan category diambil dari table parent lewat subquery
INSERT INTO transactions
    (account_id, category_id, amount, transaction_type, description)
VALUES
    -- Salary -> BCA -> income
    (
        (SELECT id FROM accounts   WHERE name = 'BCA'),
        (SELECT category_id FROM categories WHERE name = 'Salary'),
        5000000, 'income', 'Gaji bulanan'
    ),
    -- Food -> Cash -> expense
    (
        (SELECT id FROM accounts   WHERE name = 'Cash'),
        (SELECT category_id FROM categories WHERE name = 'Food'),
        35000, 'expense', 'Makan siang'
    ),
    -- Transport -> BCA -> expense
    (
        (SELECT id FROM accounts   WHERE name = 'BCA'),
        (SELECT category_id FROM categories WHERE name = 'Transport'),
        20000, 'expense', 'Ongkos transport'
    );

-- Verifikasi: pastikan account_id dan category_id
-- benar-benar berasal dari table parent (JOIN harus menghasilkan 3 baris)
SELECT
    t.transaction_id,
    u.name              AS user_name,
    a.name              AS account_name,
    c.name              AS category_name,
    t.transaction_type,
    t.amount,
    t.description
FROM transactions t
JOIN accounts   a ON a.id = t.account_id
JOIN users      u ON u.id = a.user_id
JOIN categories c ON c.category_id = t.category_id
ORDER BY t.transaction_id;

-- Verifikasi: cari orphan record (harus 0 baris)
SELECT t.*
FROM transactions t
LEFT JOIN accounts   a ON a.id = t.account_id
LEFT JOIN categories c ON c.category_id = t.category_id
WHERE a.id IS NULL OR c.category_id IS NULL;

-- 1. Membuat tabel users
CREATE TABLE users (
	id UUID,
	name VARCHAR (60),
	email VARCHAR (50),
	birth_date DATE,
	is_active BOOLEAN,
	interests TEXT[],
	metadata JSONB
);

-- 2. Membuat tabel transaction
CREATE TABLE transactions (
    id UD,
    user_id UUID,
    amountUI NUMERIC(15,2),
    description TEXT,
    transaction_date TIMESTAMP,
    metadata JSONB
);

-- 3. Insert pada tabel users
INSERT INTO users (id, name, email, birth_date, is_active, interests, metadata)
VALUES ('550e8400-e29b-41d4-a716-446655440000',
		'Agung', 
		'agung@example.com',
		'2005-05-06',
		true,
		ARRAY['gaming','eating'],
		'{"device": "android", "app_version": "1.0"}'
		);

--- 4. Mengubah struktur tabel menjadikan id sebagai PK
ALTER TABLE users
ADD CONSTRAINT users_pkey
PRIMARY KEY (id);
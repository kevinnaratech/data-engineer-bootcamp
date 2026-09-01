CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    age INT,
    total_spent NUMERIC(12,2)
);

INSERT INTO customers (id, name, city, age, total_spent)
VALUES
    (1, 'Andi', 'Jakarta', 21, 1500000),
    (2, 'Budi', 'Bandung', 25, 2300000),
    (3, 'Citra', 'Jakarta', 19, 800000),
    (4, 'Dina', 'Surabaya', 30, 4500000),
    (5, 'Eko', 'Bandung', 27, 3200000),
    (6, 'Fajar', 'Jakarta', 22, 1800000),
    (7, 'Gita', 'Surabaya', 24, 2700000),
    (8, 'Hadi', 'Bandung', 31, 5100000);

	SELECT *
FROM customers;
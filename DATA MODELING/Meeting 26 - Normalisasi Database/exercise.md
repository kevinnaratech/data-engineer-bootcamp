# Exercise — Meeting 26: Praktik Normalisasi E-Commerce

## Data Awal: `order_data`

| order_id | order_date | customer_id | customer_name | customer_email | product_id | product_name | category_id | category_name | quantity | unit_price |
|----------|------------|-------------|---------------|----------------|------------|--------------|-------------|---------------|---------:|-----------:|
| O001 | 2026-01-10 | C001 | Budi | budi@mail.com | P001 | Laptop | CAT01 | Electronics | 1 | 10000000 |
| O001 | 2026-01-10 | C001 | Budi | budi@mail.com | P002 | Mouse | CAT01 | Electronics | 2 | 250000 |
| O002 | 2026-01-11 | C002 | Andi | andi@mail.com | P001 | Laptop | CAT01 | Electronics | 1 | 10000000 |
| O003 | 2026-01-12 | C001 | Budi | budi@mail.com | P003 | Keyboard | CAT01 | Electronics | 1 | 500000 |
| O004 | 2026-01-13 | C003 | Siti | siti@mail.com | P004 | T-Shirt | CAT02 | Fashion | 3 | 150000 |

## Business Rules

- Satu customer bisa punya banyak order.
- Satu order bisa punya banyak product.
- Satu product bisa muncul di banyak order.
- Satu product hanya punya satu category.
- Satu category bisa punya banyak product.
- Satu product hanya muncul sekali dalam satu order.
- `unit_price` adalah harga product ketika transaksi terjadi.

---

## Task 1: Bedah Tabel

**Apa yang salah dengan tabel ini?**

1. **Data redundancy.** Data customer, product, dan category berulang di banyak baris.
2. **Tiga anomaly** (update, insert, dan delete anomaly).
3. **Relasi antar entity kurang jelas**, karena beberapa entity digabung dalam satu tabel.

---

## Task 2: Tentukan Struktur Tabel

**Pecah tabel tersebut menjadi entity yang tepat.**

### `customers`

| Kolom | Key |
|-------|-----|
| `customer_id` | PK |
| `customer_name` | |
| `customer_email` | |

### `orders`

| Kolom | Key |
|-------|-----|
| `order_id` | PK |
| `customer_id` | FK → `customers.customer_id` |
| `order_date` | |

### `orders_item`

| Kolom | Key |
|-------|-----|
| `order_id` | PK (composite), FK → `orders.order_id` |
| `product_id` | PK (composite), FK → `products.product_id` |
| `quantity` | |
| `unit_price` | |

### `products`

| Kolom | Key |
|-------|-----|
| `product_id` | PK |
| `product_name` | |
| `category_id` | FK → `category.category_id` |

### `category`

| Kolom | Key |
|-------|-----|
| `category_id` | PK |
| `category_name` | |

### Gambaran relasi

```text
customers
    │ 1
    │
    │ N
orders
    │ 1
    │
    │ N
orders_item
    │ N
    │
    │ 1
products
    │ N
    │
    │ 1
category
```

---

## Task 3: Dependency + Normalization

### A. Kenapa `OrderItem` membutuhkan `(order_id, product_id)` sebagai identitas?
Karena kombinasi tersebut memastikan pasangan product dan order tidak duplicate (sesuai business rule: satu product hanya muncul sekali dalam satu order), serta memastikan `order_id` dan `product_id` yang direferensikan memang ada di tabel induknya.

### B. Kenapa `product_name` tidak seharusnya berada di `OrderItem`?
Karena `product_name` hanya bergantung pada `product_id` (sebagian dari composite key), dan `orders_item.product_id` sudah merujuk ke `products` yang menyimpan `product_name`. Menyimpannya lagi di `OrderItem` menimbulkan partial dependency dan redundancy.

### C. Kenapa `category_name` tidak seharusnya berada di `Product` kalau ingin mencapai 3NF?
Karena memicu terjadinya **transitive dependency**:

```text
product_id → category_id → category_name
```

`category_name` bergantung pada `category_id` yang merupakan atribut non-key, bukan langsung pada primary key `product_id`.

---

## Task 4: Cardinality

| Relasi | Cardinality | Alasan |
|--------|-------------|--------|
| Customer → Order | 1 : N | 1 customer bisa punya banyak order |
| Order → OrderItem | 1 : N | 1 order bisa punya banyak product |
| Product → OrderItem | 1 : N | 1 product bisa muncul di banyak order |
| Category → Product | 1 : N | 1 category punya banyak product |

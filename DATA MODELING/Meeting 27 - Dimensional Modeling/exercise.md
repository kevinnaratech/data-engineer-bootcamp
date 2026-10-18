# Latihan — Pertemuan 27: Dimensional Modeling

## Data Awal

| order_id | customer | city | product | category | qty | price | order_date |
|----------|----------|------|---------|----------|----:|------:|------------|
| O001 | Budi | Jakarta | Laptop | Electronics | 1 | 10M | 2026-01-10 |
| O001 | Budi | Jakarta | Mouse | Electronics | 2 | 500K | 2026-01-10 |
| O002 | Andi | Bandung | Sepatu | Fashion | 1 | 800K | 2026-01-11 |
| O003 | Siti | Jakarta | Laptop | Electronics | 2 | 10M | 2026-01-12 |

## Kebutuhan Bisnis

Business ingin bisa menjawab:

- Berapa total revenue?
- Berapa product yang terjual?
- Product apa yang paling laku?
- Category mana yang menghasilkan revenue terbesar?
- Customer dari kota mana yang paling banyak membeli?
- Bagaimana sales per bulan?

---

## Task 1: Tentukan Grain

**Jawaban:** 1 baris pada `fact_sales` merepresentasikan 1 product pada 1 order.

---

## Task 2: Tentukan Fact

Dari kolom berikut:

```text
order_id
customer
city
product
category
qty
price
order_date
```

**Jawaban:** kolom pada `fact_sales`:

| Kolom | Jenis |
|-------|-------|
| `order_id` | identifier order |
| `customer_key` | foreign key → `dim_customer` |
| `product_key` | foreign key → `dim_product` |
| `date_key` | foreign key → `dim_date` |
| `qty` | measure |
| `price` | measure |

---

## Task 3: Tentukan Dimension

Dari kolom yang sama, tentukan dimension apa saja yang akan dibuat.

**Jawaban:**

### `dim_customer`

| Kolom | Keterangan |
|-------|------------|
| `customer_key` | surrogate key |
| `customer_id` | business key |
| `customer_name` | nama customer |
| `city` | kota customer |

### `dim_product`

| Kolom | Keterangan |
|-------|------------|
| `product_key` | surrogate key |
| `product` | nama product |
| `category` | kategori product |

### `dim_date`

| Kolom | Keterangan |
|-------|------------|
| `date_key` | surrogate key |
| `full_date` | tanggal lengkap |
| `day` | hari |
| `month` | bulan |
| `year` | tahun |

---

## Task 4: Buat Star Schema

**Jawaban:**

```text
             dim_customer
                 |
                 |
dim_product --- fact_sales --- dim_date
```

---

## Task 5: Hitung Fact Rows

Dengan grain yang dipilih:

```text
O001 → Laptop  qty 1
O001 → Mouse   qty 2
O002 → Sepatu  qty 1
O003 → Laptop  qty 2
```

Berapa rows yang akan masuk `fact_sales`, dan berapa total quantity yang terjual?

**Jawaban:** 4 rows dan total quantity 6.

**Perhitungan:** `1 + 2 + 1 + 2 = 6`
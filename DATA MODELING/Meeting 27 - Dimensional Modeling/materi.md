# Meeting 27 — Dimensional Modeling

## Ringkasan
Naik level dari relational database modeling (OLTP) ke data warehouse modeling. Mempelajari kenapa dimensional modeling dibutuhkan untuk analytics, perbedaan Fact Table dan Dimension Table, konsep Grain, Star Schema dan Snowflake Schema, perbedaan dimensional modeling dengan normalization, jenis-jenis Fact Table, serta Surrogate Key. Targetnya: mampu membaca business requirement lalu menentukan Fact, Dimension, Grain, dan Star Schema dengan alasan yang jelas.

## 1. Kenapa Dimensional Modeling?

Pada relational database (OLTP), perhatian utama kita adalah:

- menghindari redundancy,
- normalization,
- data integrity,
- transaction.

Contoh struktur OLTP:

```text
customers
orders
order_items
products
categories
```

Struktur ini bagus untuk aplikasi transaksi. Namun, ketika bisnis bertanya:

> "Berapa total revenue per category per bulan?"

atau:

> "Produk apa yang paling laku di setiap kota?"

data yang masih dalam bentuk OLTP yang sangat ternormalisasi membuat query analytics menjadi panjang dan membutuhkan banyak `JOIN`.

**Dimensional Modeling** dibuat supaya data analytics lebih mudah dipahami dan query lebih efisien.

Struktur dasarnya:

```text
             dim_customer
                  |
                  |
dim_product — fact_sales — dim_date
                  |
                  |
              dim_store
```

Struktur ini disebut **Star Schema**.

## 2. Fact Table vs Dimension Table

Ini konsep paling penting di pertemuan ini.

### Fact Table
Fact table menyimpan kejadian atau event bisnis yang bisa diukur. Contoh pada e-commerce: `sales`.

Satu baris bisa berarti *satu product yang dibeli dalam satu order*.

| order_id | product_id | customer_id | date_id | quantity | sales_amount |
|----------|------------|-------------|---------|---------:|-------------:|
| ORD001 | P001 | C001 | 20261018 | 2 | 50000 |
| ORD001 | P002 | C001 | 20261018 | 1 | 30000 |
| ORD002 | P001 | C002 | 20261019 | 3 | 75000 |

Isi fact table biasanya:

```text
foreign keys
     +
numeric measures
```

Contoh measure: `quantity`, `unit_price`, `discount`, `sales_amount`, `profit`.

### Dimension Table
Dimension menyimpan *context* atau deskripsi tentang fact. Contoh: `dim_customer`, `dim_product`, `dim_date`, `dim_category`.

Contoh `dim_product`:

| product_id | product_name | category | brand |
|------------|--------------|----------|-------|
| P001 | Keyboard | Electronics | Logitech |
| P002 | Mouse | Electronics | Razer |

### Perbedaan intinya

| Tabel | Menjawab pertanyaan |
|-------|---------------------|
| Dimension | "Fact ini terjadi terhadap siapa/apa/kapan/di mana?" |
| Fact | "Apa yang terjadi dan berapa nilainya?" |

## 3. Grain

Sebelum membuat fact table, kita tentukan dulu:

> **Satu baris pada fact table merepresentasikan apa?**

Itulah yang disebut **grain**.

Misalnya pada `fact_sales`, grain-nya:

```text
One row represents one product sold in one order.
```

Maka `ORD001 + P001` adalah satu baris. Sedangkan `ORD001` saja bukan satu baris, karena satu order bisa memiliki banyak product.

```text
Order ORD001
├── Product A
├── Product B
└── Product C
```

Hasil di fact table:

```text
ORD001 | Product A
ORD001 | Product B
ORD001 | Product C
```

Jadi satu order menghasilkan 3 baris fact.

### Kenapa grain penting?
Grain menentukan bagaimana data disimpan dan dihitung. Jika grain ambigu, bisa muncul:

- double counting,
- aggregation yang salah,
- duplicate data,
- desain fact table yang kacau.

**Aturan:** Tentukan grain **sebelum** menentukan kolom fact table.

## 4. Contoh E-Commerce

**Business requirement:** Perusahaan ingin menganalisis penjualan berdasarkan customer, product, tanggal, dan kategori.

Kita mulai dari event bisnis: *customer membeli product*. Dari situ kita punya `fact_sales` dengan dimension `dim_customer`, `dim_product`, dan `dim_date`.

```text
              dim_customer
                   |
                   |
dim_product — fact_sales — dim_date
```

### Fact

```text
fact_sales
-----------
sales_key
customer_key
product_key
date_key
order_id
quantity
unit_price
discount
sales_amount
```

### Dimension

```text
dim_customer
------------
customer_key
customer_id
customer_name
city
province

dim_product
-----------
product_key
product_id
product_name
category
brand

dim_date
--------
date_key
full_date
day
month
quarter
year
```

### Perhatikan
`fact_sales` tidak perlu menyimpan `customer_name`, `customer_city`, `product_name`, atau `product_brand`. Informasi tersebut adalah context, sehingga diletakkan di dimension.

## 5. Star Schema

Disebut Star Schema karena bentuknya seperti bintang. Fact berada di tengah, dan dimension mengelilinginya.

```text
                  dim_customer
                       |
                       |
dim_product ---- fact_sales ---- dim_date
                       |
                       |
                   dim_store
```

### Karakteristik

- Fact table berada di tengah.
- Dimension langsung berhubungan dengan fact.
- Dimension biasanya relatif denormalized.
- Query analytics lebih sederhana.

### Contoh query

```sql
SELECT
    p.category,
    d.year,
    SUM(f.sales_amount) AS revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    p.category,
    d.year;
```

Ini salah satu alasan Star Schema populer untuk analytics.

## 6. Snowflake Schema

Misalkan `dim_product` kita pecah lagi:

```text
dim_product
     |
     v
dim_category
     |
     v
dim_department
```

Sehingga skemanya menjadi:

```text
                 dim_customer
                      |
                      |
dim_product ---- fact_sales ---- dim_date
     |
     |
dim_category
```

Dimension mengalami normalization. Inilah **Snowflake Schema**.

### Star vs Snowflake

| Aspek | Star | Snowflake |
|-------|------|-----------|
| Dimension | Denormalized | Normalized |
| JOIN | Lebih sedikit | Lebih banyak |
| Query analytics | Lebih sederhana | Lebih kompleks |
| Redundancy | Lebih tinggi | Lebih rendah |
| Simplicity | Tinggi | Lebih rendah |
| Umum untuk analytics | Sangat umum | Digunakan pada kondisi tertentu |

### Contoh

**Star:**

```text
dim_product
-----------
product_id
product_name
category
department
```

**Snowflake:**

```text
dim_product
-----------
product_id
product_name
category_id
      ↓
dim_category
------------
category_id
category_name
department_id
      ↓
dim_department
--------------
department_id
department_name
```

## 7. Dimensional Modeling ≠ Normalization

Ini penting karena kita baru selesai membahas normalisasi di Pertemuan 26.

| Konteks | Pendekatan | Tujuan |
|---------|------------|--------|
| OLTP | Normalization | mengurangi redundancy |
| Data Warehouse | Dimensional Modeling | mempermudah analytics |

Jangan berpikir: *"Kalau ada duplicate category, berarti desainnya salah."* Belum tentu. Contoh pada `dim_product`:

```text
P001 | Keyboard | Electronics
P002 | Mouse    | Electronics
P003 | Monitor  | Electronics
```

"Electronics" muncul beberapa kali. Secara normalization, category bisa dipecah. Tetapi untuk analytics, redundancy tertentu bisa sengaja diterima demi kesederhanaan dan performa query. Ini adalah **trade-off**.

## 8. Contoh Business Query

Misalkan CEO bertanya:

> "Berapa revenue Electronics di Jakarta pada Januari 2026?"

Dengan Star Schema, kita bisa berpikir seperti ini:

```text
fact_sales
    |
    +-- dim_product  → category
    |
    +-- dim_customer → city
    |
    +-- dim_date     → month/year
```

Lalu kita hitung `SUM(sales_amount)` dengan filter:

```text
category = Electronics
city     = Jakarta
month    = January
year     = 2026
```

Inilah tujuan utama dimensional modeling: **membuat data mudah digunakan untuk analytical workloads.**

## 9. Jenis Fact Table

Untuk saat ini, kita kenali tiga jenis utama.

### 9.1 Transaction Fact
Setiap baris merepresentasikan transaksi atau event. Contoh: *1 product sold*. Ini yang paling umum untuk e-commerce.

### 9.2 Periodic Snapshot Fact
Menyimpan kondisi pada interval tertentu. Contoh pada banking:

```text
account_id
date_id
balance
```

Setiap hari tercatat satu baris:

```text
2026-01-01 → 10 juta
2026-01-02 → 9 juta
2026-01-03 → 12 juta
```

### 9.3 Accumulating Snapshot Fact
Digunakan untuk proses yang memiliki beberapa tahap. Contoh order:

```text
Order Created
      ↓
Paid
      ↓
Packed
      ↓
Shipped
      ↓
Delivered
```

Fact bisa menyimpan:

```text
order_id
created_date
paid_date
packed_date
shipped_date
delivered_date
```

Ini berguna untuk menganalisis *process lifecycle*.

## 10. Surrogate Key

Dalam Data Warehouse, dimension biasanya menggunakan `customer_key`, bukan hanya `customer_id`.

| customer_key | customer_id | name |
|--------------|-------------|------|
| 1 | C001 | Budi |
| 2 | C002 | Andi |

`customer_key` biasanya disebut **surrogate key**.

Konsep ini akan sangat penting ketika masuk **Pertemuan 28 — SCD (Slowly Changing Dimension)**, karena customer bisa berubah:

```text
Budi (Jakarta)
      ↓
Budi (Bandung)
```

Data Warehouse perlu menyimpan *historical state*. Itulah salah satu alasan surrogate key penting.

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| Fact table | event bisnis yang bisa diukur (foreign keys + numeric measures) |
| Dimension table | context/deskripsi: siapa, apa, kapan, di mana |
| Grain | satu baris fact table merepresentasikan apa (tentukan lebih dulu) |
| Star Schema | fact di tengah, dimension langsung mengelilingi (denormalized) |
| Snowflake Schema | dimension dinormalisasi lagi (JOIN lebih banyak) |
| Transaction fact | satu baris per transaksi/event |
| Periodic snapshot fact | kondisi pada interval tertentu (misalnya saldo harian) |
| Accumulating snapshot fact | proses bertahap dengan beberapa tanggal milestone |
| Surrogate key | key buatan di dimension (`customer_key`), mendukung historical state |

Urutan berpikir saat mendesain:

```text
1. Pahami business requirement
2. Tentukan event bisnis → fact table
3. Tentukan grain
4. Tentukan dimension (siapa, apa, kapan, di mana)
5. Tentukan measures
6. Susun Star Schema
```
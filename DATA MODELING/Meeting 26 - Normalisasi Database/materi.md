# Meeting 26 — Normalisasi Database

## Ringkasan
Mempelajari normalisasi sebagai cara mengorganisasi data di relational database supaya redundansi berkurang dan data tetap konsisten. Pembahasan meliputi tiga jenis anomaly (update, insert, delete), konsep functional dependency, bentuk normal 1NF, 2NF, dan 3NF, cara berpikir saat melakukan normalisasi, studi kasus e-commerce, serta hubungan normalisasi dengan Data Engineering (OLTP vs analytics).

## 1. Kenapa Normalisasi Dibutuhkan?

Bayangkan kita punya sistem e-commerce yang menyimpan order seperti ini:

| order_id | customer_name | customer_email | product_1 | product_2 | product_3 |
|----------|---------------|----------------|-----------|-----------|-----------|
| 1001 | Budi | budi@mail.com | Laptop | Mouse | Keyboard |
| 1002 | Andi | andi@mail.com | Monitor | NULL | NULL |

Sekilas terlihat sederhana. Namun, beberapa pertanyaan langsung muncul:

- Bagaimana kalau Budi mengganti email?
- Bagaimana kalau satu order berisi 20 produk?
- Bagaimana kalau kita ingin mencari semua order yang membeli Mouse?
- Bagaimana kalau produk punya harga, kategori, stok, dan atribut lain?
- Apakah kita harus terus menambah `product_4`, `product_5`, dan seterusnya?

Pertanyaan-pertanyaan itu menandakan bahwa struktur database kita kurang baik.

**Normalisasi** digunakan untuk mengorganisasi data sehingga:

1. mengurangi data redundancy,
2. mencegah update anomaly,
3. mencegah insert anomaly,
4. mencegah delete anomaly,
5. membuat relational database lebih konsisten.

**Catatan penting:** Normalisasi bukan berarti "semakin banyak tabel semakin bagus". Normalisasi dilakukan berdasarkan *functional dependency* dan *business rules*, bukan asal memecah tabel.

## 2. Tiga Anomaly

Tiga anomaly inilah alasan utama kenapa normalisasi ada.

### A. Update Anomaly

| order_id | customer_id | customer_name | customer_email |
|----------|-------------|---------------|----------------|
| 1001 | C01 | Budi | budi@mail.com |
| 1002 | C01 | Budi | budi@mail.com |
| 1003 | C01 | Budi | budi@mail.com |

Ketika Budi mengganti email, kita harus mengubah 3 baris. Jika hanya dua yang diubah:

```text
1001 → budi.new@mail.com
1002 → budi.new@mail.com
1003 → budi@mail.com
```

Database sekarang menyimpan informasi yang saling bertentangan (*contradictory*).

### B. Insert Anomaly

Misalkan data customer hanya bisa disimpan jika customer tersebut melakukan order. Tabelnya berisi:

```text
customer_id
customer_name
order_id
order_date
```

Ada customer baru, `C05` bernama Dina, tetapi ia belum melakukan order. Kita kesulitan memasukkan Dina karena `order_id` belum ada.

Artinya, struktur tabel mencampurkan dua entity yang berbeda: **Customer** dan **Order**.

### C. Delete Anomaly

| order_id | customer_id | customer_name |
|----------|-------------|---------------|
| 1001 | C01 | Budi |
| 1002 | C02 | Andi |

Order 1001 adalah satu-satunya order Budi. Jika order 1001 dihapus, informasi Budi ikut hilang. Padahal, menghapus sebuah order seharusnya tidak menghapus customer. Inilah delete anomaly.

## 3. Functional Dependency

Sebelum masuk ke 1NF, 2NF, dan 3NF, kita perlu memahami konsep ini.

```text
customer_id → customer_name
```

Artinya: jika kita tahu `customer_id`, kita dapat menentukan `customer_name`.

```text
C01 → Budi
C02 → Andi
```

Jika `C01` selalu berarti `Budi`, maka `customer_id → customer_name`. Hubungan inilah yang disebut **functional dependency**.

Contoh lain:

```text
product_id → product_name
product_id → product_price
```

Karena:

```text
P01 → Laptop
P01 → 15000000
```

Jadi `product_id` menentukan atribut-atribut produk.

## 4. Primary Key dan Functional Dependency

Bagian ini penting untuk data modeling. Misalkan:

```text
Order(
    order_id,
    customer_id,
    order_date
)
```

Primary key-nya `order_id`, sehingga:

```text
order_id → customer_id
order_id → order_date
```

Satu `order_id` menentukan satu customer dan satu tanggal order.

Namun, `customer_id → order_id` belum tentu benar, karena satu customer bisa punya banyak order:

```text
C01 → 1001
C01 → 1002
C01 → 1003
```

Jadi, functional dependency tidak boleh dibalik begitu saja.

## 5. 1NF — First Normal Form

Sebuah tabel memenuhi 1NF jika setiap kolom memiliki nilai yang **atomic**. Sederhananya: **satu cell = satu nilai**.

### Belum 1NF

| order_id | customer | products |
|----------|----------|----------|
| 1001 | Budi | Laptop, Mouse, Keyboard |
| 1002 | Andi | Monitor |

Kolom `products` berisi banyak nilai. Ini bermasalah karena kita tidak bisa memperlakukan setiap produk sebagai nilai individual dengan mudah.

### Bentuk 1NF

| order_id | customer | product |
|----------|----------|---------|
| 1001 | Budi | Laptop |
| 1001 | Budi | Mouse |
| 1001 | Budi | Keyboard |
| 1002 | Andi | Monitor |

Sekarang setiap cell hanya berisi satu nilai.

### Tapi masih ada masalah
1NF belum berarti database kita sudah bagus. Redundansi masih ada:

```text
1001 | Budi | Laptop
1001 | Budi | Mouse
1001 | Budi | Keyboard
```

Informasi Budi diulang di setiap baris.

## 6. 2NF — Second Normal Form

2NF berkaitan dengan **composite primary key**. Syaratnya:

1. sudah memenuhi 1NF,
2. tidak ada **partial dependency**.

Bagian ini sering membingungkan, jadi kita lihat contohnya.

```text
OrderItem
-------------------------
order_id
product_id
product_name
quantity
price
```

Primary key-nya `(order_id, product_id)`. Kenapa composite? Karena `order_id = 1001` dan `product_id = P01` bersama-sama mengidentifikasi satu item dalam order.

Sekarang kita lihat dependency-nya:

```text
(order_id, product_id) → quantity
```

Ini masuk akal. Tetapi:

```text
product_id → product_name
product_id → price
```

Artinya `product_name` dan `price` hanya bergantung pada **sebagian** primary key.

```text
Primary key:  (order_id, product_id)
                          ↑
                  hanya bagian ini yang menentukan product_name
```

Inilah **partial dependency**, sehingga tabel belum memenuhi 2NF.

### Solusinya
Pisahkan menjadi dua tabel:

```text
Product
---------
product_id PK
product_name
price

OrderItem
---------
order_id   PK/FK
product_id PK/FK
quantity
```

Sekarang `product_id → product_name` dan `product_id → price` berada di tabel `Product`, sedangkan `(order_id, product_id) → quantity` berada di `OrderItem`.

## 7. 3NF — Third Normal Form

3NF menangani **transitive dependency**. Syarat sederhananya:

1. sudah memenuhi 2NF,
2. tidak ada atribut non-key yang bergantung pada atribut non-key lainnya.

Contoh:

```text
Employee
--------------------------------
employee_id PK
employee_name
department_id
department_name
```

Dependency-nya:

```text
employee_id   → department_id
department_id → department_name
```

Akibatnya `employee_id → department_name` terjadi **melalui** `department_id`. Inilah transitive dependency.

Masalahnya terlihat pada data berikut:

| employee_id | employee_name | department_id | department_name |
|-------------|---------------|---------------|-----------------|
| E01 | Budi | D01 | Engineering |
| E02 | Andi | D01 | Engineering |
| E03 | Siti | D01 | Engineering |

Nilai "Engineering" diulang berkali-kali.

### Solusi 3NF

```text
Employee
--------
employee_id PK
employee_name
department_id FK

Department
----------
department_id PK
department_name
```

Dependency menjadi lebih jelas, dan `department_name` tidak lagi berada di tabel `Employee`:

```text
employee_id   → department_id
department_id → department_name
```

## 8. Cara Berpikir Saat Normalisasi

Hindari pola pikir "ada banyak data, pecah saja tabelnya". Gunakan langkah berikut.

### Step 1 — Identifikasi entity
Tanyakan: *"Data ini sebenarnya tentang apa?"* Pada contoh e-commerce:

```text
Customer
Product
Order
OrderItem
Category
```

### Step 2 — Tentukan candidate/primary key

```text
Customer   → customer_id
Product    → product_id
Order      → order_id
OrderItem  → (order_id, product_id)
```

`OrderItem` bisa menggunakan composite key, tergantung business rules.

### Step 3 — Cari functional dependency

```text
customer_id → customer_name, customer_email
product_id  → product_name, product_price
order_id    → customer_id, order_date
(order_id, product_id) → quantity
```

### Step 4 — Cari partial dependency
Terutama jika primary key-nya composite, misalnya `(order_id, product_id)`. Tanyakan: apakah ada atribut yang hanya bergantung pada `order_id` saja atau `product_id` saja? Jika ada, berarti ada masalah 2NF.

### Step 5 — Cari transitive dependency
Tanyakan: *"Apakah atribut non-key bergantung pada atribut non-key lain?"*

```text
employee_id
    ↓
department_id
    ↓
department_name
```

Jika ya, berarti ada masalah 3NF.

## 9. Studi Kasus E-Commerce

Perhatikan tabel awal berikut:

| order_id | order_date | customer_id | customer_name | customer_email | product_id | product_name | category_id | category_name | quantity | unit_price |
|----------|------------|-------------|---------------|----------------|------------|--------------|-------------|---------------|----------|------------|
| O001 | 2026-01-01 | C01 | Budi | budi@mail.com | P01 | Laptop | CAT01 | Electronics | 2 | 10000000 |
| O001 | 2026-01-01 | C01 | Budi | budi@mail.com | P02 | Mouse | CAT01 | Electronics | 1 | 250000 |
| O002 | 2026-01-02 | C02 | Andi | andi@mail.com | P01 | Laptop | CAT01 | Electronics | 1 | 10000000 |

Jangan langsung membuat tabel. Cari dependency-nya terlebih dahulu:

```text
customer_id → customer_name, customer_email
product_id  → product_name, category_id
category_id → category_name
order_id    → order_date, customer_id
(order_id, product_id) → quantity
```

Dari sini terlihat kenapa data tersebut tidak seharusnya disimpan dalam satu tabel besar.

Hasil desain yang ternormalisasi kira-kira mengarah ke:

```text
Customer
    ↓
Order
    ↓
OrderItem
    ↓
Product
    ↓
Category
```

Perhatikan bahwa kita belum membahas dimensional modeling di sini. Ini masih OLTP / relational modeling.

Di Pertemuan 27, perspektifnya dibalik: *"Kalau data ini digunakan untuk analytics, apakah struktur normalized seperti ini masih ideal?"* Di situlah kita masuk ke **Star Schema**.

## 10. Normalisasi dan Data Engineering

Di lingkungan production, kita akan menemukan beberapa layer data, misalnya:

```text
Source System
     ↓
Raw Data
     ↓
Staging
     ↓
Normalized / ODS
     ↓
Data Warehouse
     ↓
Data Mart
```

Normalisasi sangat relevan ketika bekerja dengan:

- transactional database,
- operational database,
- OLTP,
- source systems,
- data integrity.

Untuk analytics, kita sering melakukan **denormalization** melalui dimensional modeling.

Karena itu, jangan berpikir bahwa "normalized = selalu bagus". Yang lebih tepat: **desain harus mengikuti workload dan business requirement.**

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| Update anomaly | data yang sama harus diubah di banyak baris, risiko tidak konsisten |
| Insert anomaly | data tidak bisa disimpan karena entity lain belum ada |
| Delete anomaly | menghapus satu data ikut menghilangkan informasi lain |
| Functional dependency | `A → B`: mengetahui A cukup untuk menentukan B |
| 1NF | satu cell = satu nilai (atomic) |
| 2NF | sudah 1NF + tidak ada partial dependency pada composite key |
| 3NF | sudah 2NF + tidak ada transitive dependency antar atribut non-key |
| Partial dependency | atribut hanya bergantung pada sebagian dari composite key |
| Transitive dependency | atribut non-key bergantung pada atribut non-key lain |

Langkah normalisasi:

```text
1. Identifikasi entity
2. Tentukan primary key
3. Cari functional dependency
4. Cari partial dependency (2NF)
5. Cari transitive dependency (3NF)
```

# Meeting 28 — Slowly Changing Dimension (SCD)

## Ringkasan
Mempelajari strategi menangani perubahan data pada Dimension Table di Data Warehouse tanpa kehilangan history. Pembahasan meliputi SCD Type 1 (overwrite), Type 2 (baris baru dengan history), dan Type 3 (nilai sekarang dan sebelumnya), peran surrogate key, struktur dimension untuk Type 2, alur prosesnya, contoh implementasi di PostgreSQL, serta hubungannya dengan Fact Table untuk historical analysis.

## Latar Belakang

Pada pertemuan sebelumnya sudah membahas Star Schema dan Dimension Table. Sekarang masuk ke masalah penting di Data Warehouse:

> Bagaimana kalau data di Dimension berubah, tetapi kita tetap ingin menjaga history?

Contoh paling sederhana: customer pindah kota.

## 1. Apa Itu SCD?

**Slowly Changing Dimension (SCD)** adalah strategi untuk menangani perubahan data pada Dimension Table dalam Data Warehouse.

Misalnya awalnya:

| customer_id | name | city |
|-------------|------|------|
| C001 | Budi | Jakarta |

Budi kemudian pindah ke Bandung, sehingga data di source sekarang:

| customer_id | name | city |
|-------------|------|------|
| C001 | Budi | Bandung |

Pertanyaannya: **apakah kita overwrite Jakarta menjadi Bandung, atau menyimpan keduanya?**

Jawabannya tergantung kebutuhan bisnis. Inilah yang diselesaikan oleh SCD Type 1, 2, dan 3.

## 2. SCD Type 1

### Konsep
Menimpa (*overwrite*) data lama dengan data baru.

Sebelum:

| customer_id | name | city |
|-------------|------|------|
| C001 | Budi | Jakarta |

Setelah Budi pindah ke Bandung:

| customer_id | name | city |
|-------------|------|------|
| C001 | Budi | Bandung |

Jakarta hilang.

### Kapan digunakan?
Jika history tidak penting, misalnya:

- typo nama customer,
- typo email,
- koreksi nomor telepon,
- data yang memang hanya membutuhkan nilai terkini (*current value*).

### Contoh

```sql
UPDATE dim_customer
SET city = 'Bandung'
WHERE customer_id = 'C001';
```

### Kelebihan dan kekurangan

| Kelebihan | Kekurangan |
|-----------|------------|
| sederhana | history hilang |
| storage kecil | |
| query mudah | |

## 3. SCD Type 2

Ini yang paling penting untuk Data Engineer.

Type 2 **tidak** menimpa record lama. Kita membuat **baris baru** untuk setiap perubahan.

Misalnya awalnya:

| customer_sk | customer_id | name | city |
|-------------|-------------|------|------|
| 101 | C001 | Budi | Jakarta |

Setelah Budi pindah ke Bandung:

| customer_sk | customer_id | name | city | valid_from | valid_to | is_current |
|-------------|-------------|------|------|------------|----------|------------|
| 101 | C001 | Budi | Jakarta | 2026-01-01 | 2026-10-18 | false |
| 205 | C001 | Budi | Bandung | 2026-10-19 | NULL | true |

Perhatikan: `customer_id` tetap `C001`, tetapi `customer_sk` berbeda.

### Kenapa perlu `customer_sk`?
Ini konsep penting.

- `customer_id` adalah **business key / natural key** dari source system.
- `customer_sk` adalah **surrogate key** yang digunakan Data Warehouse.

Alasannya, satu customer bisa mempunyai beberapa record historis:

```text
C001
 ├── customer_sk 101 → Jakarta
 └── customer_sk 205 → Bandung
```

Jika fact table menyimpan `customer_sk = 101`, transaksi tersebut tetap terhubung ke versi customer ketika ia masih tinggal di Jakarta.

## 4. Kenapa SCD Type 2 Penting untuk Analytics?

Misalkan Budi membeli laptop pada Januari ketika ia tinggal di Jakarta, lalu pada Oktober ia pindah ke Bandung.

Jika kita menggunakan Type 1, datanya menjadi `Budi → Bandung`. Ketika analyst bertanya:

> "Berapa penjualan dari customer yang tinggal di Jakarta?"

transaksi lama Budi bisa terlihat seolah-olah berasal dari Bandung. History menjadi salah.

Dengan Type 2:

```text
January transaction
       ↓
customer_sk = 101
       ↓
Jakarta
```

dan transaksi setelah pindah:

```text
October transaction
       ↓
customer_sk = 205
       ↓
Bandung
```

Dengan begitu, kita bisa melakukan *historical analysis* dengan benar.

## 5. Struktur Dimension SCD Type 2

Struktur umum:

```text
dim_customer
--------------------------------
customer_sk       PK
customer_id       Business Key
customer_name
city
valid_from
valid_to
is_current
```

Contoh data:

| customer_sk | customer_id | customer_name | city | valid_from | valid_to | is_current |
|-------------|-------------|---------------|------|------------|----------|------------|
| 1 | C001 | Budi | Jakarta | 2026-01-01 | 2026-05-31 | false |
| 2 | C001 | Budi | Bandung | 2026-06-01 | NULL | true |
| 3 | C002 | Andi | Surabaya | 2026-01-01 | NULL | true |

Tiga konsep yang perlu dipahami:

| Kolom | Fungsi |
|-------|--------|
| `customer_sk` | surrogate key |
| `valid_from` / `valid_to` | menentukan kapan sebuah record berlaku |
| `is_current` | menentukan record yang sedang aktif |

## 6. Bagaimana Proses SCD Type 2 Bekerja?

Misalkan source berisi:

```text
C001 | Budi | Jakarta
```

### Step 1 — Insert record pertama
Belum ada `C001` di warehouse, jadi kita insert:

```text
C001 | Budi | Jakarta | 2026-01-01 | NULL | true
```

Kemudian source berubah menjadi `C001 | Budi | Bandung`. ETL mendeteksi:

```text
old city = Jakarta
new city = Bandung
```

### Step 2 — Tutup record lama

```text
C001 | Budi | Jakarta | 2026-01-01 | 2026-10-18 | false
```

### Step 3 — Insert record baru

```text
C001 | Budi | Bandung | 2026-10-19 | NULL | true
```

Jadi kita **bukan** meng-`UPDATE` city dari Jakarta menjadi Bandung. Kita melakukan:

```text
close old record
        +
insert new record
```

Inilah inti SCD Type 2.

## 7. SCD Type 3

Type 3 menyimpan nilai lama dan nilai baru dalam **satu baris yang sama**.

| customer_id | name | current_city | previous_city |
|-------------|------|--------------|---------------|
| C001 | Budi | Bandung | Jakarta |

Ketika Budi pindah lagi ke Surabaya:

| customer_id | name | current_city | previous_city |
|-------------|------|--------------|---------------|
| C001 | Budi | Surabaya | Bandung |

Jakarta sudah hilang. Jadi Type 3 hanya menyimpan *limited history*.

### Kapan digunakan?
Ketika bisnis hanya membutuhkan nilai sekarang dan nilai sebelumnya (`current value + previous value`), tanpa seluruh history.

## 8. Perbandingan Type 1, 2, dan 3

| Aspek | Type 1 | Type 2 | Type 3 |
|-------|--------|--------|--------|
| History | Tidak | Ya | Terbatas |
| Row baru | Tidak | Ya | Tidak |
| Storage | Kecil | Lebih besar | Sedang |
| Complexity | Rendah | Tinggi | Sedang |
| Historical analysis | Tidak | Sangat baik | Terbatas |
| Umum di Data Warehouse | Ya | Sangat umum | Lebih jarang |

Yang paling penting diingat:

```text
Type 1 → overwrite
Type 2 → new row + history
Type 3 → current + previous value
```

## 9. Contoh PostgreSQL: SCD Type 2

Membuat tabel dimension:

```sql
CREATE TABLE dim_customer (
    customer_sk SERIAL PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_current BOOLEAN NOT NULL
);
```

Data awal:

```sql
INSERT INTO dim_customer
(customer_id, customer_name, city, valid_from, valid_to, is_current)
VALUES
('C001', 'Budi', 'Jakarta', '2026-01-01', NULL, TRUE);
```

Kemudian Budi pindah. **Tutup record lama:**

```sql
UPDATE dim_customer
SET
    valid_to = '2026-10-18',
    is_current = FALSE
WHERE customer_id = 'C001'
  AND is_current = TRUE;
```

**Insert versi baru:**

```sql
INSERT INTO dim_customer
(customer_id, customer_name, city, valid_from, valid_to, is_current)
VALUES
('C001', 'Budi', 'Bandung', '2026-10-19', NULL, TRUE);
```

Hasil:

| customer_sk | customer_id | customer_name | city | valid_from | valid_to | is_current |
|-------------|-------------|---------------|------|------------|----------|------------|
| 101 | C001 | Budi | Jakarta | 2026-01-01 | 2026-10-18 | false |
| 205 | C001 | Budi | Bandung | 2026-10-19 | NULL | true |

**Catatan:** Nilai `customer_sk` (101 dan 205) pada hasil di atas hanya ilustrasi. Karena kolomnya `SERIAL`, nilai aslinya di-generate otomatis oleh PostgreSQL (mulai dari 1, 2, dan seterusnya).

## 10. Hubungan dengan Fact Table

Bagian ini sangat penting bagi calon Data Engineer.

```text
dim_customer

customer_sk | customer_id | city
------------+-------------+--------
101         | C001        | Jakarta
205         | C001        | Bandung
```

```text
fact_sales

sale_id | customer_sk | amount
--------+-------------+--------
S001    | 101         | 5000000
S002    | 205         | 3000000
```

Artinya:

```text
S001 → Budi ketika di Jakarta
S002 → Budi ketika di Bandung
```

Jadi Fact Table menyimpan surrogate key dari **versi dimension yang benar pada saat transaksi terjadi**.

Ini salah satu alasan kenapa kita mempelajari rangkaian berikut:

```text
Star Schema
      ↓
Dimension
      ↓
SCD Type 2
      ↓
Historical Fact
```

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| SCD | strategi menangani perubahan data pada Dimension Table |
| Type 1 | overwrite, history hilang |
| Type 2 | tutup record lama, insert record baru, history lengkap |
| Type 3 | satu baris menyimpan nilai sekarang dan sebelumnya |
| Business key | `customer_id`, identifier dari source system |
| Surrogate key | `customer_sk`, identifier internal Data Warehouse |
| `valid_from` / `valid_to` | masa berlaku sebuah versi record |
| `is_current` | penanda versi yang sedang aktif |

Alur SCD Type 2:

```text
Deteksi perubahan di source
          ↓
Close record lama (valid_to, is_current = false)
          ↓
Insert record baru (valid_from, valid_to = NULL, is_current = true)
```

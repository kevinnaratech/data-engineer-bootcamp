# Meeting 30 — ETL vs ELT, Batch vs Streaming

## Ringkasan
Membahas dua cara membangun data pipeline: ETL dan ELT, yang bedanya ada di *di mana dan kapan* transformation dilakukan. Dilanjutkan dengan Batch vs Streaming, yaitu bagaimana data mengalir dan seberapa sering diproses. Dua hal ini adalah dimensi yang berbeda, jadi keempatnya bisa dikombinasikan (Batch ETL, Batch ELT, dan seterusnya).

## 1. ETL

Baik ETL maupun ELT punya tujuan yang sama:

```text
Ambil data dari source → proses data → simpan ke destination
```

Bedanya cuma satu: **di mana transformation dilakukan**.

### Alur ETL

```text
Source
  ↓
Extract
  ↓
Transform
  ↓
Load
  ↓
Data Warehouse / Database
```

Transformation dilakukan **sebelum** data masuk ke destination.

### Contoh
API mengirim data seperti ini:

```json
{
  "name": "Budi",
  "age": "21",
  "email": " BUDI@EMAIL.COM "
}
```

Pipeline-nya:

```text
API
 ↓
Extract
 ↓
Transform
 ├── age → integer
 ├── email → lowercase
 └── trim whitespace
 ↓
Load
 ↓
PostgreSQL
```

Jadi PostgreSQL menerima data yang sudah ditransformasi.

## 2. ELT

ELT membalik urutannya.

```text
Source
  ↓
Extract
  ↓
Load
  ↓
Data Warehouse
  ↓
Transform
  ↓
Analytics-ready data
```

Data mentah dimasukkan dulu ke destination, baru ditransformasi di sana.

### Contoh

```text
API
 ↓
Extract
 ↓
Load
 ↓
raw_customers
 ↓
SQL Transformation
 ↓
customers
```

Transformation-nya bisa dilakukan pakai SQL di data warehouse atau database.

## 3. Kenapa ELT Populer di Modern Data Engineering?

Karena data warehouse modern (terutama cloud warehouse) punya compute yang sangat kuat.

```text
API / Application / Event
          ↓
       Raw Data
          ↓
   Data Warehouse
          ↓
   SQL Transformation
          ↓
       Data Mart
```

Daripada Python mengerjakan semua transformation sebelum loading, kita bisa simpan raw data dulu, lalu manfaatkan compute warehouse.

### Keuntungan penting: Reproducibility

Misalnya transformation kita ternyata salah.

**Kalau pakai ETL:**

```text
Source
 ↓
Transformation v1
 ↓
Database
```

Raw data mungkin sudah nggak tersedia lagi.

**Kalau pakai ELT:**

```text
Source
 ↓
raw_data
 ↓
Transformation v1
```

Kita masih punya `raw_data`, jadi bisa:

```text
raw_data
 ↓
Transformation v2
```

Hasil transformation tinggal di-*rebuild*. Ini penting banget di production pipeline.

## 4. Jadi, ETL Lebih Buruk?

Nggak. Ini kesalahan yang sering terjadi waktu belajar Data Engineering.

Jangan berpikir:

> ELT = modern = bagus, ETL = kuno.

Yang benar:

> Pilih berdasarkan kebutuhan sistem.

### ETL cocok untuk

```text
API
 ↓
Python
 ↓
Cleaning
 ↓
PostgreSQL
```

Misalnya data yang masuk harus dibersihkan dulu karena destination hanya boleh menerima data dengan format tertentu.

### ELT cocok untuk

```text
Application
 ↓
Raw data
 ↓
Data Warehouse
 ↓
SQL
 ↓
Analytics tables
```

Terutama kalau warehouse punya compute besar dan kita ingin mempertahankan raw data.

### Perbandingan singkat

| Aspek | ETL | ELT |
|-------|-----|-----|
| Urutan | Extract → Transform → Load | Extract → Load → Transform |
| Transformation dilakukan | sebelum masuk destination | di dalam destination (warehouse) |
| Raw data | belum tentu disimpan | disimpan di destination |
| Alat transformation umum | Python / script | SQL di warehouse |
| Cocok untuk | destination yang hanya boleh menerima data dengan format tertentu | warehouse dengan compute besar, raw data ingin dipertahankan |

## 5. Batch vs Streaming

Sekarang masuk dimensi yang berbeda dari ETL vs ELT. **Jangan dicampur.**

| Perbandingan | Menjawab pertanyaan |
|--------------|---------------------|
| ETL vs ELT | "Transformation dilakukan kapan dan di mana?" |
| Batch vs Streaming | "Data diproses seberapa sering / bagaimana data mengalir?" |

### Batch
Data dikumpulkan dulu, lalu diproses sekaligus.

```text
00:00 ─────────────── 01:00
       collect data
             ↓
          process
             ↓
          database
```

Contoh: setiap jam, ambil transaksi satu jam terakhir lalu masukkan ke warehouse.

### Streaming
Data diproses begitu event/data datang.

```text
Event → Event → Event → Event
   ↓       ↓       ↓       ↓
        Processing
             ↓
        Destination
```

Contoh: setiap transaksi pembayaran terjadi, event-nya langsung diproses.

## 6. Keempat Konsep Ini Bisa Dikombinasikan

Ini bagian penting buat mindset Data Engineer.

### Batch ETL

```text
API
 ↓
Extract
 ↓
Python Transform
 ↓
PostgreSQL
```

Dijalankan setiap 1 jam.

### Batch ELT

```text
CSV
 ↓
Load raw data
 ↓
Warehouse
 ↓
SQL Transform
```

Dijalankan setiap malam.

### Streaming
Bisa juga berupa sistem streaming yang melakukan transformation sebelum atau di dalam processing layer.

### Intinya

```text
ETL vs ELT       → transformation architecture
Batch vs Stream  → processing pattern
```

Keduanya bukan pilihan dari satu kategori yang sama.

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| ETL | transform dulu, baru load ke destination |
| ELT | load raw data dulu, transform di destination |
| Reproducibility | dengan ELT, raw data masih ada sehingga transformation bisa diulang (v1 → v2) |
| Batch | data dikumpulkan lalu diproses sekaligus (misalnya tiap jam) |
| Streaming | data diproses begitu event datang |
| Kombinasi | Batch ETL, Batch ELT, atau streaming, tergantung kebutuhan |

Pegangan utamanya:

```text
ETL vs ELT       = kapan dan di mana transformation
Batch vs Stream  = seberapa sering dan bagaimana data mengalir
`
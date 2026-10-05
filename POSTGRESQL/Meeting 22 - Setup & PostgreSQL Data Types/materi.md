# Meeting 22 — PostgreSQL dan Tipe Data

## Ringkasan
Pertemuan ini membahas dasar-dasar PostgreSQL sebagai Relational Database Management System (RDBMS), perbedaan antara SQL dan PostgreSQL, serta peran pgAdmin sebagai antarmuka grafis. Pembahasan dilanjutkan dengan pembuatan database dan tabel, konsep tipe data (`INTEGER`, `NUMERIC`, `VARCHAR`, `TEXT`, `BOOLEAN`, `DATE`, `TIMESTAMP`, `UUID`), tipe data khusus PostgreSQL (`ARRAY` dan `JSONB`), perbedaan tipe data dengan constraint, serta keterkaitan pemilihan tipe data dengan kualitas data dan performa dalam Data Engineering.

## 1. Pengertian PostgreSQL

PostgreSQL adalah *Relational Database Management System* (RDBMS), yaitu perangkat lunak yang mengelola data dalam bentuk tabel yang saling berelasi. Secara sederhana, hubungan antara aplikasi dan data dapat digambarkan sebagai berikut.

```text
Application
     ↓
PostgreSQL
     ↓
Database
     ↓
Tables
     ↓
Rows + Columns
```

Contoh tabel `users`:

```text
users

id | name  | email
---+-------+------------------
1  | Agung | agung@example.com
2  | Budi  | budi@example.com
```

PostgreSQL menyimpan data secara terstruktur dan menyediakan mekanisme untuk:

- menyimpan data,
- mengambil data,
- mengubah data,
- menghapus data,
- menjaga integritas data,
- menjalankan transaksi (*transaction*),
- melakukan pengindeksan (*indexing*), dan
- menjalankan *query* yang kompleks.

### 1.1 PostgreSQL dan SQL

Kedua istilah ini tidak boleh dipertukarkan.

- **SQL** adalah bahasa *query* standar untuk berinteraksi dengan *relational database*.
- **PostgreSQL** adalah sistem manajemen basis data yang mengimplementasikan SQL dan menyediakan banyak fitur tambahan.

Contoh fitur yang khas PostgreSQL:

- `JSONB`
- `ARRAY`
- dukungan `UUID`
- *Materialized View*

Dengan demikian, **SQL ≠ PostgreSQL**. PostgreSQL menggunakan SQL, tetapi memiliki fitur di luar standar SQL.

## 2. Pengertian pgAdmin

pgAdmin adalah antarmuka grafis (*graphical interface*) untuk PostgreSQL. Alih-alih bekerja sepenuhnya melalui terminal, pengguna dapat menelusuri struktur server secara visual.

```text
Servers
 └── PostgreSQL
      └── Databases
           └── Schemas
                └── Tables
                     └── Columns
```

Kegunaan pgAdmin antara lain:

- menjalankan SQL,
- melihat database, tabel, dan kolom,
- melihat isi data,
- melakukan administrasi database, dan
- membantu *debugging* database.

**Catatan:** Seorang Data Engineer tidak boleh bergantung pada antarmuka grafis. Kemampuan bekerja langsung menggunakan SQL tetap merupakan keharusan.

## 3. Database dan Table

### 3.1 Database
*Database* adalah wadah (*container*) bagi berbagai objek basis data. Contoh: `finance_db`, yang di dalamnya dapat memuat tabel `users`, `accounts`, `transactions`, dan `categories`.

### 3.2 Table
*Table* digunakan untuk menyimpan data dalam struktur baris (*row*) dan kolom (*column*).

```text
users

id | name  | email
---+-------+----------------
1  | Agung | agung@email.com
2  | Budi  | budi@email.com
```

Analogi sederhana:

| Konsep | Analogi |
|--------|---------|
| Database | lemari |
| Table | laci |
| Row | satu *record* |
| Column | atribut dari *record* |

## 4. Membuat Database

```sql
CREATE DATABASE finance_db;
```

Perintah di atas membuat sebuah database baru. Setelah itu, pengguna perlu terhubung (*connect*) ke database tersebut.

**Catatan:** `CREATE DATABASE` adalah perintah SQL untuk membuat database, sedangkan proses *connect* bergantung pada klien yang digunakan, misalnya pgAdmin, `psql`, atau aplikasi lain.

## 5. Membuat Table

Sintaks dasar:

```sql
CREATE TABLE users (
    id UUID,
    name VARCHAR(60),
    email VARCHAR(100),
    birth_date DATE,
    is_active BOOLEAN
);
```

Struktur tabel tersebut:

```text
users
│
├── id          → UUID
├── name        → VARCHAR(60)
├── email       → VARCHAR(100)
├── birth_date  → DATE
└── is_active   → BOOLEAN
```

Pada pernyataan `name VARCHAR(60)`, `name` adalah **nama kolom**, sedangkan `VARCHAR(60)` adalah **tipe data**.

## 6. Tipe Data

Tipe data (*data type*) menentukan jenis data yang dapat disimpan dalam sebuah kolom.

```text
name       → teks
age        → bilangan bulat
salary     → angka presisi
is_active  → boolean
birth_date → tanggal
```

Tipe data penting karena basis data perlu mengetahui makna data yang disimpan. Perhatikan perbedaan berikut:

```sql
age INTEGER
age VARCHAR(10)
```

Keduanya dapat menyimpan nilai `25`, tetapi maknanya berbeda. Dengan `age INTEGER`, database memahami bahwa `age` adalah angka sehingga operasi seperti `age + 1` dan `age > 18` dievaluasi dengan semantik numerik yang tepat.

### 6.1 INTEGER
Digunakan untuk bilangan bulat.

```sql
age INTEGER
quantity INTEGER
```

Contoh nilai: `18`, `25`, `30`, `42`. Tipe ini tidak cocok untuk `18.5` atau `99.99` karena bukan bilangan bulat.

### 6.2 NUMERIC
Digunakan untuk angka yang membutuhkan presisi, terutama nilai finansial.

```sql
amount NUMERIC(12,2)
```

Artinya:

- `12` = total jumlah digit,
- `2` = jumlah digit di belakang koma.

Contoh nilai: `1500.00`, `250000.50`, `99.99`.

Untuk nilai moneter yang membutuhkan aritmetika desimal eksak, tipe *floating-point* sebaiknya tidak digunakan sembarangan. Misalnya, `amount NUMERIC(15,2)` lebih masuk akal untuk jumlah transaksi.

### 6.3 VARCHAR
Digunakan untuk string/teks dengan batas panjang tertentu.

```sql
name VARCHAR(100)
```

`VARCHAR(100)` **tidak** berarti string otomatis dipanjangkan menjadi 100 karakter. Angka tersebut adalah batasan panjang maksimum (*maximum length constraint*) pada deklarasi tipe.

### 6.4 TEXT
PostgreSQL juga menyediakan `TEXT` untuk string tanpa batas panjang yang ditentukan.

```sql
description TEXT
notes TEXT
```

`TEXT` sering menjadi pilihan yang baik ketika tidak ada kebutuhan panjang maksimum tertentu. Lebih tepat menggunakan `description TEXT` daripada memaksakan `VARCHAR(500)` tanpa alasan bisnis yang jelas.

**Aturan penting:** Batas seperti `VARCHAR(50)` tidak boleh ditentukan hanya karena kebiasaan. Batas harus ditentukan berdasarkan kebutuhan (*requirement*).

### 6.5 BOOLEAN
Digunakan untuk nilai logika `TRUE` atau `FALSE`.

```sql
is_active BOOLEAN
is_verified BOOLEAN
is_deleted BOOLEAN
is_paid BOOLEAN
```

Jika domain data hanya "aktif" atau "tidak aktif", `BOOLEAN` lebih tepat daripada `is_active VARCHAR(10)`. Tipe teks membuka kemungkinan nilai tidak konsisten seperti `yes`, `no`, `active`, `inactive`, `maybe`, `iya`, atau `nggak`.

### 6.6 DATE
Menyimpan tanggal saja.

```sql
birth_date DATE
```

Contoh nilai: `2005-05-06`. Cocok untuk tanggal lahir, tanggal libur, tanggal faktur (*invoice date*), tanggal jatuh tempo (*due date*), dan tanggal transaksi apabila waktu dalam hari tidak diperlukan.

### 6.7 TIMESTAMP
Menyimpan tanggal sekaligus waktu.

```sql
created_at TIMESTAMP
```

Contoh nilai: `2026-10-05 16:30:45`.

```text
DATE       → 2026-10-05
TIMESTAMP  → 2026-10-05 16:30:45
```

Pada konteks produksi, kolom seperti `transaction_at TIMESTAMP` dipakai untuk peristiwa (*event*) karena yang diperlukan adalah kapan transaksi terjadi, bukan hanya tanggalnya.

### 6.8 DATE dibandingkan TIMESTAMP
Pemilihan tidak cukup dihafal, melainkan harus didasarkan pada kebutuhan bisnis.

| Kasus | Tipe | Alasan |
|-------|------|--------|
| Tanggal lahir | `DATE` | jam lahir biasanya tidak diperlukan pada aplikasi *finance tracker* |
| Waktu transaksi | `TIMESTAMP` | urutan dan waktu transaksi dapat menjadi penting |

Contoh urutan transaksi yang membutuhkan `TIMESTAMP`:

```text
2026-10-05 08:15:00
2026-10-05 12:30:00
2026-10-05 18:45:00
```

### 6.9 UUID
*UUID* (*Universally Unique Identifier*) adalah pengenal unik yang digunakan sebagai identitas.

```sql
id UUID
```

Contoh nilai: `550e8400-e29b-41d4-a716-446655440000`.

Berbeda dengan `INTEGER` yang berurutan (`1`, `2`, `3`, ...), UUID dapat dibuat tanpa bergantung pada satu *sequence* global. Karakteristik ini sesuai untuk sistem terdistribusi:

```text
Service A → generate UUID
Service B → generate UUID
Service C → generate UUID
```

Risiko tabrakan (*collision*) sangat rendah.

UUID berguna ketika:

- data dibuat oleh banyak *service*,
- sistem bersifat terdistribusi,
- ID terekspos melalui API,
- data perlu digabung dari berbagai sumber, atau
- diinginkan identifier yang tidak mudah ditebak seperti integer berurutan.

Contoh perbandingan:

```text
GET /users/550e8400-e29b-41d4-a716-446655440000
GET /users/123
```

**Catatan:** UUID tidak otomatis membuat sistem lebih aman, tetapi identifier berurutan memang lebih mudah ditebak.

### 6.10 UUID dibandingkan INTEGER
Tidak benar bahwa UUID selalu lebih baik.

| Aspek | INTEGER | UUID |
|-------|---------|------|
| Ukuran | kecil | lebih besar |
| Kesederhanaan | sederhana, mudah dibaca | lebih panjang |
| Ukuran index | lebih kecil | bisa lebih besar |
| Keunikan global | tidak | ya |
| Cocok untuk | banyak sistem internal | sistem terdistribusi |
| Berurutan | ya | tidak secara default |

UUID acak dapat memiliki *locality* yang lebih buruk dibandingkan identifier berurutan. Karena itu, pemilihan UUID atau integer merupakan **keputusan arsitektural**, bukan sekadar gaya penulisan.

## 7. Tipe Data Khusus PostgreSQL

### 7.1 ARRAY
PostgreSQL mendukung *array* sebagai tipe data, sehingga satu baris dapat memiliki beberapa nilai sekaligus.

```sql
interests TEXT[]
```

Contoh data:

```text
users

name  | interests
------+------------------
Agung | {gaming,eating}
Budi  | {football,music}
```

`TEXT[]` adalah fitur khas PostgreSQL. Tipe ini cocok untuk koleksi sederhana, misalnya seorang pengguna memiliki beberapa minat (`gaming`, `music`, `reading`) yang dapat disimpan sebagai `{gaming,music,reading}`.

**Menyisipkan data array:**

```sql
INSERT INTO users (
    id,
    name,
    interests
)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'Agung',
    ARRAY['gaming', 'eating']
);
```

`ARRAY['gaming', 'eating']` adalah *array constructor* milik PostgreSQL.

**ARRAY bukan pengganti tabel relasional.** `interests TEXT[]` cocok untuk koleksi sederhana, tetapi tidak berarti setiap daftar harus disimpan sebagai `ARRAY`. Misalkan pada sistem *e-commerce* satu produk dapat memiliki banyak kategori. Hal itu merupakan relasi, sehingga desain relasional lebih tepat:

```text
products
    ↓
product_categories
    ↓
categories
```

dibandingkan:

```text
products
categories TEXT[]
```

Desain relasional diperlukan karena relasi membutuhkan:

- integritas referensial (*referential integrity*),
- *foreign key*,
- kemudahan *query*,
- penghilangan duplikasi (*deduplication*),
- metadata tambahan, dan
- skalabilitas.

**Konsep query pada ARRAY.** Pada data `{gaming,eating}`, kondisi `interests = 'gaming'` tidak tepat karena memperlakukan `interests` sebagai satu string. Pertanyaan yang sebenarnya adalah: *apakah "gaming" merupakan salah satu elemen dalam array?* PostgreSQL menyediakan operator khusus untuk itu.

```sql
'gaming' = ANY(interests)
interests @> ARRAY['gaming']
```

- `'gaming' = ANY(interests)` berarti apakah `'gaming'` sama dengan salah satu elemen dalam `interests`.
- `interests @> ARRAY['gaming']` berarti array `interests` mengandung elemen `'gaming'`.

Keduanya valid untuk kasus tertentu. Yang terpenting adalah memahami bahwa array membutuhkan operasi yang memperhitungkan strukturnya.

### 7.2 JSONB
`JSONB` digunakan untuk menyimpan data semi-terstruktur (*semi-structured data*).

```sql
metadata JSONB
```

Contoh nilai:

```json
{
    "device": "android",
    "app_version": "1.0",
    "language": "id"
}
```

**Metadata** secara sederhana adalah *data tentang data*. Pada pengguna dengan `name = Agung`, nama merupakan data utama, sedangkan informasi seperti perangkat, versi aplikasi, dan bahasa merupakan konteks tambahan tentang pengguna atau peristiwa.

**Alasan menggunakan JSONB.** Aplikasi dapat terus menambah atribut metadata dari waktu ke waktu:

```text
Hari ini:   {"device": "android"}
Besok:      {"device": "android", "app_version": "2.1.0"}
Kemudian:   {"device": "android", "app_version": "2.1.0",
             "language": "id", "campaign": "ramadhan"}
```

Jika setiap atribut dibuat sebagai kolom (`device`, `app_version`, `language`, `campaign`, ...), tabel dapat membesar dengan sangat cepat. Untuk data yang benar-benar fleksibel, `JSONB` dapat menjadi tempat menyimpan atribut tambahan tersebut.

**JSON dan JSONB:**

| Tipe | Karakteristik |
|------|---------------|
| `JSON` | menyimpan JSON dalam representasi berbentuk teks |
| `JSONB` | menyimpan dalam representasi biner yang dioptimalkan PostgreSQL untuk pemrosesan |

Dalam banyak kasus aplikasi PostgreSQL yang membutuhkan *query* atau *indexing* terhadap JSON, `JSONB` lebih praktis.

**JSONB bersifat khas PostgreSQL.** JSON merupakan format data yang umum, sedangkan `JSONB` adalah fitur PostgreSQL. Apabila berpindah ke sistem basis data lain, sintaks dan perilaku `JSONB` tidak otomatis dapat dipindahkan satu-satu. Namun, konsep data semi-terstruktur tetap sangat dapat dipindahkan dalam Data Engineering.

**Menyisipkan data JSONB:**

```sql
INSERT INTO users (
    id,
    name,
    metadata
)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'Agung',
    '{"device": "android", "app_version": "1.0"}'
);
```

PostgreSQL menyimpan objek tersebut sebagai `JSONB` karena kolom `metadata` bertipe `JSONB`.

**Jangan memasukkan semua data ke dalam JSONB.** Ini adalah jebakan yang sering dialami pemula. Desain seperti berikut tidak dianjurkan:

```sql
users (
    id UUID,
    metadata JSONB
)
```

dengan seluruh data pengguna di dalam `metadata`:

```json
{
    "name": "Agung",
    "email": "agung@example.com",
    "birth_date": "2005-05-06",
    "is_active": true
}
```

Field seperti `name`, `email`, `birth_date`, dan `is_active` memiliki struktur yang jelas dan stabil, sehingga sebaiknya menjadi kolom relasional. `JSONB` digunakan untuk atribut tambahan yang fleksibel.

## 8. Memilih Antara Kolom Biasa, ARRAY, dan JSONB

| Jenis data | Contoh | Pilihan |
|------------|--------|---------|
| Nilai tunggal terstruktur | `name`, `email`, `birth_date`, `salary` | kolom biasa |
| Koleksi sederhana | `gaming`, `music`, `reading` | `ARRAY`, jika relasinya sederhana dan tidak memerlukan entitas relasional |
| Atribut fleksibel semi-terstruktur | `device`, `app_version`, `campaign` | `JSONB` |
| Relasi antar entitas | user ↔ role, product ↔ category, student ↔ course | tabel relasional / *junction table*, bukan otomatis `ARRAY` |

## 9. Tipe Data dan Constraint

Keduanya adalah konsep yang berbeda.

- **Tipe data** menjawab pertanyaan: *"Data ini jenisnya apa?"* Contoh: `UUID`, `INTEGER`, `TEXT`, `BOOLEAN`.
- **Constraint** menjawab pertanyaan: *"Aturan apa yang harus dipatuhi data ini?"* Contoh: `PRIMARY KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`.

Pada contoh berikut:

```sql
id UUID PRIMARY KEY
```

`UUID` adalah tipe data, sedangkan `PRIMARY KEY` adalah constraint. Keduanya tidak boleh dicampuradukkan. Constraint akan dibahas lebih mendalam pada Pertemuan 23.

## 10. Penerapan pada Proyek Personal Finance Tracker

### 10.1 Tabel `users` (tahap awal)

```sql
CREATE TABLE users (
    id UUID,
    name VARCHAR(100),
    email TEXT,
    birth_date DATE,
    is_active BOOLEAN,
    interests TEXT[],
    metadata JSONB
);
```

Tabel ini belum siap produksi karena constraint belum dibahas. Tujuan pada tahap ini adalah mempelajari tipe data dan struktur awal.

### 10.2 Tabel `transactions`

```sql
CREATE TABLE transactions (
    id UUID,
    user_id UUID,
    amount NUMERIC(15,2),
    description TEXT,
    transaction_date TIMESTAMP,
    metadata JSONB
);
```

Alasan pemilihan tipe:

| Kolom | Tipe | Alasan |
|-------|------|--------|
| `id` | `UUID` | identifier unik |
| `user_id` | `UUID` | merujuk ke `users.id` |
| `amount` | `NUMERIC(15,2)` | nilai uang butuh presisi |
| `description` | `TEXT` | panjang tidak ditentukan |
| `transaction_date` | `TIMESTAMP` | waktu transaksi penting |
| `metadata` | `JSONB` | atribut tambahan yang fleksibel |

Tipe data tidak boleh dipilih berdasarkan kebiasaan, melainkan berdasarkan **semantik data**.

## 11. Praktik Terbaik Pemilihan Tipe Data

| Hindari | Gunakan | Keterangan |
|---------|---------|------------|
| `age VARCHAR(10)` | `age INTEGER` | jika `age` memang angka |
| `is_active VARCHAR(10)` | `is_active BOOLEAN` | untuk nilai benar/salah |
| `amount VARCHAR(50)` | `amount NUMERIC(15,2)` | untuk nilai uang |
| `birth_date TIMESTAMP` | `birth_date DATE` | jika hanya tanggal lahir yang dibutuhkan |

## 12. Keterkaitan dengan Data Engineering

Pemilihan tipe data bukan hanya urusan pengembang basis data. Data Engineer juga sangat bergantung padanya.

```text
Application
     ↓
PostgreSQL
     ↓
ETL / ELT
     ↓
Data Warehouse
     ↓
Analytics
```

Jika basis data sumber menyimpan `amount VARCHAR`, pipeline dapat menghadapi masalah saat melakukan transformasi `VARCHAR → NUMERIC`, karena data dapat berisi nilai seperti `"100000"`, `"250000"`, `"N/A"`, `"unknown"`, atau `"gratis"`. Nilai-nilai tersebut menimbulkan masalah kualitas data (*data quality*). Sebaliknya, jika sumber menggunakan `amount NUMERIC(15,2)`, basis data sudah membantu menjaga domain data tersebut.

> Desain basis data yang baik membantu menjaga kualitas data sebelum data masuk ke pipeline.

### 12.1 Tipe Data dan Kualitas Data
Pada `is_active BOOLEAN`, domain datanya jelas: `TRUE` atau `FALSE`. Bandingkan dengan `is_active TEXT` yang memungkinkan `true`, `TRUE`, `yes`, `Yes`, `active`, `aktif`, atau `1`. Semakin longgar tipe yang digunakan tanpa alasan, semakin banyak pekerjaan pembersihan data (*data cleaning*) yang muncul di pipeline. Dengan demikian, **skema basis data merupakan salah satu lapisan kualitas data**.

### 12.2 Tipe Data dan Performa
Tipe data memengaruhi:

- penyimpanan (*storage*),
- memori,
- ukuran *index*,
- performa *query*, dan
- transfer data.

Sebagai contoh, `INTEGER` lebih kecil dibandingkan string seperti `"123456"`, dan basis data dapat melakukan operasi numerik secara langsung. Anggapan bahwa "penyimpanan sekarang besar sehingga tipe data bebas" tidak tepat. Pada lingkungan produksi, jumlah data dapat mencapai 10 juta, 100 juta, bahkan 1 miliar baris, sehingga perbedaan desain yang kecil dapat berdampak besar ketika skala meningkat.

## Cheat Sheet

| Tipe Data | Kegunaan | Contoh |
|-----------|----------|--------|
| `INTEGER` | bilangan bulat | `age`, `quantity` |
| `NUMERIC(p,s)` | angka presisi (uang) | `amount NUMERIC(15,2)` |
| `VARCHAR(n)` | string dengan batas panjang | `name VARCHAR(100)` |
| `TEXT` | string tanpa batas ditentukan | `description TEXT` |
| `BOOLEAN` | benar/salah | `is_active` |
| `DATE` | tanggal | `birth_date` |
| `TIMESTAMP` | tanggal + waktu | `transaction_date` |
| `UUID` | identifier unik global | `id UUID` |
| `TEXT[]` | koleksi sederhana (PostgreSQL) | `interests` |
| `JSONB` | data semi-terstruktur (PostgreSQL) | `metadata` |

| Konsep | Penjelasan |
|--------|------------|
| Tipe data | jenis data yang disimpan kolom |
| Constraint | aturan yang harus dipatuhi data |
| `'x' = ANY(arr)` | `x` sama dengan salah satu elemen array |
| `arr @> ARRAY['x']` | array mengandung elemen `x` |

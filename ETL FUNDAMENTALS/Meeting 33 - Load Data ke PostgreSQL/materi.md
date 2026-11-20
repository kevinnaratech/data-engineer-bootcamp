# Meeting 33 — Load Data ke PostgreSQL (Project 2)

## Ringkasan
Membahas tahap Load pada ETL pipeline: memasukkan data yang sudah diekstrak, ditransformasi, dan divalidasi ke PostgreSQL. Meliputi koneksi Python ke PostgreSQL (`psycopg2` dan SQLAlchemy), pengelolaan koneksi dengan environment variable, perbandingan row-by-row insert dan bulk insert, parameter `if_exists`, database transaction (commit dan rollback), error handling saat loading, prinsip schema dibuat eksplisit lewat SQL, dan implementasi loading dalam pipeline.

## 1. Apa Itu Data Loading?

**Data loading** adalah proses memasukkan data yang sudah diekstrak, ditransformasi, dan divalidasi ke dalam target database atau data warehouse.

Dalam pipeline kita:

```text
Public API
    ↓
Extract — Requests
    ↓
Transform — Pandas
    ↓
Data Quality Checks
    ↓
Load — PostgreSQL
```

**Contoh kasus:** kita mengambil data pengguna dari API, membersihkannya dengan Pandas, lalu menyimpannya ke tabel `dim_users` di PostgreSQL.

Tujuannya bukan sekadar memindahkan data, tetapi memastikan data masuk dengan benar, konsisten, dan tidak merusak data yang sudah ada sebelumnya.

## 2. Menghubungkan Python dengan PostgreSQL

Ada dua pendekatan yang perlu dipahami.

### A. psycopg2
`psycopg2` adalah PostgreSQL database adapter untuk Python. Dengan library ini kita bisa mengeksekusi SQL secara langsung menggunakan *cursor*.

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="etl_project",
    user="postgres",
    password="password",
    port=5432
)

cursor = conn.cursor()

cursor.execute("SELECT * FROM users")
result = cursor.fetchall()
print(result)

cursor.close()
conn.close()
```

Konsep penting:

| Method | Fungsi |
|--------|--------|
| `connect()` | membuat koneksi |
| `cursor()` | membuat cursor untuk menjalankan SQL |
| `execute()` | menjalankan SQL |
| `fetchall()` | mengambil seluruh hasil query |
| `commit()` | menyimpan perubahan transaksi |
| `rollback()` | membatalkan transaksi |
| `close()` | menutup koneksi atau cursor |

### B. SQLAlchemy
SQLAlchemy adalah SQL toolkit dan ORM untuk Python. Library ini menyediakan abstraction sehingga kita tidak perlu mengelola semua interaksi database secara manual.

```python
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql+psycopg2://postgres:password@localhost:5432/etl_project"
)
```

### Perbedaan psycopg2 dan SQLAlchemy

| psycopg2 | SQLAlchemy |
|----------|------------|
| database driver | SQL toolkit dan ORM |
| kontrol SQL langsung | abstraction lebih tinggi |
| menggunakan cursor | menggunakan engine dan connection |
| manual transaction | mendukung transaction context |

**Pilihan untuk Project 2: SQLAlchemy.** Alasannya, kita akan mengintegrasikan Pandas dengan PostgreSQL dan membangun pipeline yang lebih modular.

Dokumentasi:

- [psycopg2 Documentation](https://www.psycopg.org/docs/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

## 3. Membuat Koneksi Database

Sebaiknya koneksi database dipisahkan dari proses extract dan transform.

Contoh struktur project:

```text
etl_project/
│
├── extract/
│   └── extract_api.py
│
├── transform/
│   └── transform_data.py
│
├── load/
│   ├── db_connection.py
│   └── load_data.py
│
├── config/
│
├── main.py
└── requirements.txt
```

File `db_connection.py`:

```python
import os
from sqlalchemy import create_engine

def get_engine():
    database_url = os.getenv("DATABASE_URL")
    engine = create_engine(database_url)
    return engine
```

Di sini kita menggunakan **environment variable**. Contoh `.env`:

```text
DATABASE_URL=postgresql+psycopg2://postgres:password@localhost:5432/etl_project
```

### Kenapa pakai environment variables?

- Password tidak ditulis langsung di source code.
- Konfigurasi bisa berbeda antara development dan production.
- Lebih aman ketika project diunggah ke GitHub.

**Jangan lupa** masukkan `.env` ke `.gitignore`.

## 4. Row-by-row Insert vs Bulk Insert

Ini salah satu konsep paling penting dalam loading.

### A. Row-by-row insert
Data dimasukkan satu per satu.

```python
for row in data:
    cursor.execute(
        """
        INSERT INTO users (id, name)
        VALUES (%s, %s)
        """,
        (row["id"], row["name"])
    )
```

Misalnya ada 100.000 rows, maka program melakukan operasi insert berulang kali. Kekurangannya:

- banyak database round trips,
- overhead komunikasi lebih besar,
- umumnya lebih lambat untuk data besar.

### B. Bulk insert
Memasukkan banyak rows dalam satu operasi atau beberapa batch. Contoh menggunakan Pandas:

```python
df.to_sql(
    name="users",
    con=engine,
    if_exists="append",
    index=False,
    method="multi",
    chunksize=1000
)
```

| Parameter | Fungsi |
|-----------|--------|
| `name` | nama tabel tujuan |
| `con` | database connection atau engine |
| `if_exists` | perilaku jika tabel sudah ada |
| `index` | apakah index DataFrame ikut dimasukkan |
| `method` | metode insert |
| `chunksize` | jumlah rows per batch |

**Kenapa pakai bulk insert?** Karena mengurangi overhead komunikasi antara Python dan database. Untuk data besar, bulk loading biasanya lebih efisien.

**Catatan:** `method="multi"` bukan satu-satunya metode bulk loading. PostgreSQL juga menyediakan mekanisme seperti `COPY`, yang sangat berguna untuk volume data besar.

## 5. Memahami `if_exists`

Parameter `if_exists` menentukan tindakan Pandas ketika tabel tujuan sudah tersedia.

| Value | Perilaku |
|-------|----------|
| `fail` | menghasilkan error jika tabel sudah ada |
| `replace` | menghapus tabel lama lalu membuat tabel baru |
| `append` | menambahkan data ke tabel yang sudah ada |

```python
df.to_sql(
    name="users",
    con=engine,
    if_exists="append",
    index=False
)
```

### Kenapa memilih `append`?
Dalam pipeline ETL, sering kali kita ingin mempertahankan data yang sudah ada dan menambahkan data baru.

Namun, hati-hati. Jika API mengirim data yang sama pada setiap pipeline run, `append` bisa menghasilkan **duplicate records**.

Run pertama:

| id | name |
|----|------|
| 1 | Leanne |
| 2 | Ervin |

Run kedua (data yang sama):

| id | name |
|----|------|
| 1 | Leanne |
| 2 | Ervin |

Kalau langsung `append`, tabel berisi empat rows, padahal seharusnya hanya dua.

Solusinya bisa menggunakan:

- primary key dan unique constraints,
- upsert,
- deduplication,
- strategi incremental loading.

Untuk PostgreSQL, upsert dapat dilakukan dengan `INSERT ... ON CONFLICT`.

## 6. Database Transaction

**Transaction** adalah sekumpulan operasi database yang diperlakukan sebagai satu kesatuan. Konsep ini berhubungan dengan ACID yang sudah dipelajari sebelumnya.

Misalnya pipeline melakukan:

1. insert ke `dim_users`,
2. insert ke `fact_orders`,
3. update metadata pipeline.

Bagaimana jika operasi ketiga gagal? Kita tidak ingin database berada dalam kondisi setengah berhasil.

### Commit
Menyimpan seluruh perubahan transaksi.

```python
conn.commit()
```

### Rollback
Membatalkan perubahan transaksi yang belum di-commit.

```python
conn.rollback()
```

### Menggunakan SQLAlchemy
SQLAlchemy menyediakan transaction context:

```python
from sqlalchemy import text

with engine.begin() as conn:
    conn.execute(
        text("INSERT INTO users (id, name) VALUES (1, 'Leanne')")
    )
```

Jika berhasil, transaction di-commit. Jika terjadi exception, transaction di-rollback.

Contoh yang lebih lengkap:

```python
from sqlalchemy import text

try:
    with engine.begin() as conn:
        conn.execute(
            text("""
                INSERT INTO users (id, name)
                VALUES (:id, :name)
            """),
            {"id": 1, "name": "Leanne"}
        )
except Exception as e:
    print(f"Loading failed: {e}")
```

### Kenapa transaction penting dalam ETL?
Bayangkan pipeline memasukkan 10.000 rows, tetapi gagal pada proses tertentu. Tanpa pengelolaan transaction yang tepat, database bisa menyimpan sebagian data dan berada dalam kondisi tidak konsisten. Transaction membantu menjaga **atomicity**.

**Catatan:** pastikan seluruh operasi yang harus berhasil bersama berada dalam transaction yang sama. Jangan melakukan commit per row jika kita membutuhkan atomicity untuk seluruh batch.

## 7. Error Handling saat Loading

Database loading bisa mengalami berbagai error.

| Error | Penyebab |
|-------|----------|
| Connection error | PostgreSQL tidak bisa diakses |
| Authentication error | username/password salah |
| Undefined table | tabel belum tersedia |
| Unique violation | data melanggar unique constraint |
| Foreign key violation | referensi data tidak valid |
| Data type error | tipe data tidak sesuai |
| Timeout | operasi melebihi batas waktu |

Contoh menangani error:

```python
from sqlalchemy.exc import SQLAlchemyError

try:
    df.to_sql(
        name="users",
        con=engine,
        if_exists="append",
        index=False
    )
except SQLAlchemyError as e:
    print(f"Database error: {e}")
    raise
```

### Kenapa pakai `raise`?
Karena error tidak boleh disembunyikan. Pipeline harus tahu bahwa loading gagal agar proses tidak menganggap ETL berhasil.

Di production, kita akan menggunakan logging, bukan hanya `print()`. Implementasi logging dibahas lebih dalam di **Pertemuan 34**.

## 8. Jangan Biarkan Pandas Mendesain Schema Production

Ini best practice yang perlu diingat. Misalnya kita melakukan:

```python
df.to_sql(
    name="users",
    con=engine,
    if_exists="replace",
    index=False
)
```

Pandas dapat membuat tabel berdasarkan struktur DataFrame. Namun, untuk pipeline yang serius, sebaiknya schema database dibuat **secara eksplisit menggunakan SQL**:

```sql
CREATE TABLE dim_users (
    user_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);
```

Setelah itu Pandas dipakai untuk memasukkan data ke tabel yang sudah tersedia.

### Kenapa?

- Kita mengontrol tipe data.
- Constraints tetap terjaga.
- Primary key dan foreign key jelas.
- Schema tidak berubah sembarangan.
- Database lebih mudah dikelola.

**Ingat:** Python bertanggung jawab memproses data, PostgreSQL bertanggung jawab menjaga integritas data.

## 9. Implementasi Loading dalam ETL Pipeline

Sekarang kita gabungkan konsepnya. Misalnya kita sudah punya DataFrame hasil transform.

### Alur loading

| Langkah | Penjelasan |
|---------|------------|
| 1. Get database connection | mengambil SQLAlchemy engine |
| 2. Validate DataFrame | memastikan kolom dan tipe data sesuai |
| 3. Load data | menggunakan bulk insert atau batch loading |
| 4. Commit transaction | memastikan perubahan berhasil disimpan |
| 5. Handle errors | rollback dan catat kegagalan jika terjadi error |

Contoh implementasi sederhana:

```python
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

def load_data(df, engine):
    try:
        with engine.begin() as conn:
            df.to_sql(
                name="dim_users",
                con=conn,
                if_exists="append",
                index=False,
                method="multi",
                chunksize=1000
            )
        print("Data successfully loaded")

    except SQLAlchemyError:
        print("Failed to load data")
        raise
```

Ini masih versi dasar. Untuk production, kita perlu menambahkan validasi schema, pengelolaan duplicate, logging, dan strategi loading yang sesuai dengan kebutuhan data.

Dokumentasi resmi: [pandas `to_sql()`](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.to_sql.html)

## 10. Ringkasan Pertemuan 33

| Materi | Hal yang harus dipahami |
|--------|-------------------------|
| `psycopg2` | PostgreSQL driver |
| SQLAlchemy | database toolkit dan ORM |
| Engine | pengelola koneksi database |
| Row-by-row | insert satu per satu |
| Bulk insert | insert banyak rows |
| `chunksize` | ukuran batch |
| `if_exists` | strategi ketika tabel sudah ada |
| Transaction | menjaga konsistensi operasi |
| Commit | menyimpan perubahan |
| Rollback | membatalkan perubahan |
| Upsert | insert atau update berdasarkan konflik |
| Schema | struktur tabel database |

Alur Project 2 sejauh ini:

```text
Extract (P31)  →  Transform (P32)  →  Load (P33)  →  Logging & Retry (P34)
```

# Meeting 32 — Transform Data (Python & Pandas)

## Ringkasan
Membahas tahap Transform pada ETL: mengubah raw data dari API menjadi data yang bersih, konsisten, dan siap dimasukkan ke PostgreSQL. Meliputi pengenalan Pandas (Series dan DataFrame), data cleaning (missing values dan duplicate), standardization, konversi tipe data, transformasi tanggal, perataan nested JSON, data quality checks, struktur transformation yang modular, hubungannya dengan Data Warehouse (Star Schema), serta best practices.

## 1. Pengertian Data Transformation

**Data Transformation** adalah proses mengubah data mentah menjadi data yang sesuai dengan kebutuhan sistem atau database tujuan.

Dalam ETL, alurnya seperti ini:

```text
Source API
    |
    v
  Extract
    |
    v
  Raw Data
    |
    v
 Transform
    |
    +-- Data Cleaning
    +-- Data Standardization
    +-- Data Type Conversion
    +-- Data Validation
    |
    v
 Clean Data
    |
    v
  Load
    |
    v
PostgreSQL
```

### Kenapa transformation diperlukan?
Data dari API tidak selalu siap digunakan. Contoh raw data:

```json
{
    "id": "101",
    "name": "  JOHN DOE ",
    "email": "JOHN@GMAIL.COM",
    "age": "22",
    "city": null
}
```

Permasalahannya:

- `id` masih berbentuk string.
- `name` memiliki whitespace.
- `email` menggunakan uppercase.
- `age` masih berbentuk string.
- `city` memiliki missing value.

Transformation bertugas menangani permasalahan tersebut berdasarkan aturan bisnis.

### Tujuan Data Transformation
1. Meningkatkan kualitas data.
2. Menyamakan format data.
3. Memastikan konsistensi tipe data.
4. Menghilangkan data yang tidak valid sesuai aturan.
5. Menyesuaikan data dengan struktur database tujuan.
6. Menyiapkan data untuk analytics.

## 2. Mengenal Pandas

**Pandas** adalah library Python untuk manipulasi dan analisis data berbentuk tabular.

Pandas banyak dipakai dalam Data Engineering untuk:

- memproses data dari API,
- membaca CSV dan Excel,
- membersihkan data,
- mengubah struktur data,
- melakukan validasi,
- menyiapkan data sebelum loading ke database.

Instalasi dan import:

```bash
pip install pandas
```

```python
import pandas as pd
```

### A. Series
Series adalah struktur data satu dimensi.

```python
import pandas as pd

data = [10, 20, 30, 40]
series = pd.Series(data)

print(series)
```

Output:

```text
0    10
1    20
2    30
3    40
dtype: int64
```

Series memiliki *index* dan *value*.

### B. DataFrame
DataFrame adalah struktur data dua dimensi berbentuk tabel yang terdiri dari baris dan kolom.

```python
data = {
    "name": ["Alice", "Bob", "Charlie"],
    "age": [21, 25, 23],
    "city": ["Jakarta", "Bandung", "Surabaya"]
}

df = pd.DataFrame(data)
print(df)
```

Output:

| Index | name | age | city |
|-------|------|-----|------|
| 0 | Alice | 21 | Jakarta |
| 1 | Bob | 25 | Bandung |
| 2 | Charlie | 23 | Surabaya |

Perbedaan Series dan DataFrame:

| Series | DataFrame |
|--------|-----------|
| satu dimensi | dua dimensi |
| satu kolom data | banyak kolom |
| memiliki index | memiliki index dan column |

### C. Mengubah JSON menjadi DataFrame
API biasanya memberikan data dalam format JSON.

```python
data = [
    {"id": 1, "name": "Alice", "age": 21},
    {"id": 2, "name": "Bob", "age": 25},
    {"id": 3, "name": "Charlie", "age": 23}
]

df = pd.DataFrame(data)
```

Dengan Pandas, data tersebut bisa langsung diolah seperti tabel database.

### D. Memahami DataFrame
Beberapa method dan attribute penting:

| Method / Attribute | Fungsi |
|--------------------|--------|
| `df.head()` | menampilkan 5 baris pertama |
| `df.tail()` | menampilkan 5 baris terakhir |
| `df.info()` | informasi struktur dan tipe data |
| `df.describe()` | statistik deskriptif |
| `df.shape` | jumlah baris dan kolom |
| `df.columns` | daftar nama kolom |
| `df.dtypes` | tipe data setiap kolom |
| `df.isnull().sum()` | jumlah missing value |

## 3. Data Cleaning

**Data Cleaning** adalah proses mendeteksi, memperbaiki, atau menangani data yang bermasalah. Tujuannya memastikan data memenuhi standar kualitas sebelum digunakan.

### A. Missing Values
Missing value adalah nilai yang tidak tersedia atau kosong.

| id | name | age |
|----|------|-----|
| 1 | Alice | 21 |
| 2 | Bob | NULL |
| 3 | NULL | 23 |

Di Pandas, missing value dapat direpresentasikan sebagai `None`, `NaN`, `NaT`, atau `pd.NA`.

**Mendeteksi missing values:**

```python
df.isnull()                  # True/False untuk setiap cell
df.isnull().sum()            # jumlah missing value per kolom
df.isnull().sum().sum()      # total seluruh missing value
```

**Menghapus missing values:**

```python
df.dropna()                       # hapus row yang punya minimal satu missing value
df.dropna(subset=["name"])        # hapus row berdasarkan kolom tertentu
```

**Mengisi missing values:**

```python
df["age"] = df["age"].fillna(0)                      # nilai tertentu
df["age"] = df["age"].fillna(df["age"].mean())       # rata-rata
df["age"] = df["age"].fillna(df["age"].median())     # median
df["name"] = df["name"].fillna("Unknown")            # nilai default
```

**Hal penting dalam Data Engineering:** jangan sembarangan menghapus atau mengisi missing value. Contohnya, `age = 0` belum tentu berarti umur sebenarnya nol, bisa jadi datanya memang tidak tersedia. Keputusan harus berdasarkan business rules.

### B. Duplicate Records
Duplicate adalah record yang muncul lebih dari sekali.

| id | name | city |
|----|------|------|
| 1 | Alice | Jakarta |
| 2 | Bob | Bandung |
| 1 | Alice | Jakarta |

**Mendeteksi duplicate:**

```python
df.duplicated()            # True/False untuk setiap row
df.duplicated().sum()      # jumlah duplicate
```

**Menghapus duplicate:**

```python
df.drop_duplicates()
df.drop_duplicates(subset=["id"])      # berdasarkan kolom tertentu

df.drop_duplicates(
    subset=["id"],
    keep="first"                       # menentukan record yang dipertahankan
)
```

Parameter `keep`:

| Parameter | Fungsi |
|-----------|--------|
| `first` | mempertahankan record pertama |
| `last` | mempertahankan record terakhir |
| `False` | menghapus seluruh record yang terduplikasi |

### Business key dan duplicate
Duplicate tidak selalu berarti seluruh kolom bernilai sama.

| customer_id | name | updated_at |
|-------------|------|------------|
| 1 | Alice | 2026-01-01 |
| 1 | Alice Smith | 2026-01-02 |

Kedua record punya ID yang sama, tetapi datanya berbeda. Bisa jadi record kedua merupakan pembaruan data. Karena itu, Data Engineer harus menentukan:

- business key,
- aturan deduplication,
- record mana yang harus dipertahankan,
- apakah data lama harus di-update atau disimpan sebagai history.

## 4. Data Standardization

**Data Standardization** adalah proses menyamakan format data agar konsisten.

Contoh masalah:

```text
" ALICE "
"alice"
"ALICE"
```

Ketiganya berformat berbeda meskipun mungkin merepresentasikan nilai yang sama.

```python
df["name"] = df["name"].str.strip()      # A. hilangkan whitespace
df["email"] = df["email"].str.lower()    # B. lowercase
df["name"] = df["name"].str.upper()      # C. uppercase
df["name"] = df["name"].str.title()      # D. title case (john doe → John Doe)
```

**E. Mengganti karakter atau format:**

```python
df["phone"] = df["phone"].str.replace("-", "", regex=False)
```

Contoh: `0812-3456-7890` menjadi `081234567890`.

### Kenapa standardization penting?
Format data yang tidak konsisten dapat menyebabkan:

- kesulitan melakukan `JOIN`,
- kesalahan grouping,
- kesulitan melakukan deduplication,
- data analytics menjadi tidak akurat.

## 5. Data Type Conversion

**Data Type Conversion** adalah proses mengubah tipe data agar sesuai dengan kebutuhan sistem.

API sering mengirimkan angka dalam bentuk string:

```json
{
    "id": "101",
    "price": "15000",
    "quantity": "5"
}
```

Padahal kita ingin memprosesnya sebagai numeric.

### A. Menggunakan `astype()`

```python
df["id"] = df["id"].astype(int)          # menjadi integer
df["price"] = df["price"].astype(float)  # menjadi float
```

### B. Menggunakan `pd.to_numeric()`

```python
df["price"] = pd.to_numeric(
    df["price"],
    errors="coerce"
)
```

Parameter `errors`:

| Value | Fungsi |
|-------|--------|
| `raise` | menghasilkan error jika konversi gagal |
| `coerce` | mengubah nilai invalid menjadi `NaN` |
| `ignore` | mempertahankan nilai jika konversi gagal (deprecated pada Pandas 2.2) |

`to_numeric()` berguna ketika data mengandung nilai yang formatnya tidak konsisten.

### C. Mengubah menjadi datetime

```python
df["created_at"] = pd.to_datetime(
    df["created_at"]
)
```

Untuk menangani tanggal invalid:

```python
df["created_at"] = pd.to_datetime(
    df["created_at"],
    errors="coerce"
)
```

Tanggal invalid akan menjadi `NaT`.

### D. Mapping Pandas ke PostgreSQL

| Pandas | PostgreSQL |
|--------|------------|
| `int64` | `BIGINT` |
| `int32` | `INTEGER` |
| `float64` | `DOUBLE PRECISION` |
| `object` | `TEXT` / `VARCHAR` |
| `bool` | `BOOLEAN` |
| `datetime64[ns]` | `TIMESTAMP` |

Mapping ini hanya panduan umum. Untuk nilai uang, misalnya, `NUMERIC` di PostgreSQL biasanya lebih tepat daripada floating-point.

## 6. Date and Time Transformation

Data tanggal sering ditemukan di API dan butuh standardisasi. Contoh format yang berbeda-beda:

```text
2026-01-15
15/01/2026
January 15, 2026
```

Kita bisa mengubahnya menjadi tipe datetime:

```python
df["date"] = pd.to_datetime(df["date"])
```

### Mengambil komponen tanggal

```python
df["year"] = df["date"].dt.year              # tahun
df["month"] = df["date"].dt.month            # bulan
df["day"] = df["date"].dt.day                # hari
df["day_name"] = df["date"].dt.day_name()    # nama hari
```

### Kenapa penting?
Dalam Data Engineering, data tanggal sering digunakan untuk:

- partitioning,
- incremental loading,
- time-based aggregation,
- daily reporting,
- data warehouse analytics.

## 7. Transformasi Struktur Data JSON

Data API sering memiliki struktur **nested JSON**.

```json
{
    "id": 1,
    "name": "John Doe",
    "address": {
        "street": "Kulas Light",
        "city": "Gwenborough"
    },
    "company": {
        "name": "Romaguera-Crona"
    }
}
```

Struktur ini tidak langsung berbentuk tabel sederhana. Targetnya:

| id | name | city | company_name |
|----|------|------|--------------|
| 1 | John Doe | Gwenborough | Romaguera-Crona |

### A. Mengakses nested JSON

```python
df["address"]                                   # kolom nested

df["address"].apply(lambda x: x["city"])        # mengambil city
df["company"].apply(lambda x: x["name"])        # mengambil nama perusahaan
```

### B. Menggunakan `pd.json_normalize()`
Pandas menyediakan fungsi untuk meratakan nested JSON.

```python
pd.json_normalize(data)
```

Contoh kolom hasilnya:

```text
id
name
address.street
address.city
company.name
```

Kita bisa memilih kolom tertentu dan mengganti namanya sesuai kebutuhan.

**Kapan digunakan?** `json_normalize()` cocok ketika API mengirimkan nested JSON dan kita ingin mengubahnya menjadi struktur tabular. Namun, untuk struktur nested yang kompleks atau memiliki array bersarang, proses transformasi tambahan mungkin diperlukan.

## 8. Data Quality Checks

**Data Quality Checks** adalah proses memeriksa apakah data memenuhi standar kualitas yang sudah ditentukan.

Perbedaan mendasarnya:

| Data Cleaning | Data Quality Checks |
|---------------|---------------------|
| memperbaiki data | memeriksa kualitas data |
| menangani missing values | memastikan kolom wajib tidak `NULL` |
| menghapus duplicate | memastikan key unik |
| standardization | memastikan format sesuai aturan |
| mengubah tipe data | memastikan tipe data sesuai schema |

Beberapa jenis validasi penting:

### A. Null Validation

```python
if df["id"].isnull().any():
    raise ValueError("ID cannot be NULL")
```

Memastikan tidak ada ID kosong.

### B. Uniqueness Validation

```python
if df["id"].duplicated().any():
    raise ValueError("Duplicate ID detected")
```

Memastikan ID unik.

### C. Schema Validation
Misalnya kita mengharapkan kolom berikut:

```python
expected_columns = [
    "id",
    "name",
    "email",
    "age"
]
```

Memeriksa kolom yang hilang:

```python
missing_columns = set(expected_columns) - set(df.columns)

if missing_columns:
    raise ValueError(
        f"Missing columns: {missing_columns}"
    )
```

Schema validation penting karena struktur API bisa berubah sewaktu-waktu.

### D. Data Type Validation

```python
if df["id"].dtype != "int64":
    raise ValueError("Invalid ID data type")
```

### E. Business Rule Validation
Contoh aturan bisnis:

- harga tidak boleh negatif,
- umur tidak boleh negatif,
- quantity harus lebih besar dari nol,
- email wajib tersedia.

```python
if (df["price"] < 0).any():
    raise ValueError("Price cannot be negative")
```

### F. Range Validation
Contoh umur harus berada pada rentang 0–120:

```python
if not df["age"].between(0, 120).all():
    raise ValueError("Invalid age range")
```

## 9. Data Transformation dengan Function

Di project Data Engineering, logic transformation sebaiknya dipisahkan ke dalam function. Tujuannya:

- reusability,
- readability,
- maintainability,
- easier testing,
- separation of concerns.

Contoh struktur:

```python
def clean_data(df):
    pass

def standardize_data(df):
    pass

def validate_data(df):
    pass

def transform_data(data):
    pass
```

Pembagian tanggung jawab:

| Function | Tanggung jawab |
|----------|----------------|
| `clean_data()` | menangani missing values dan duplicates |
| `standardize_data()` | menyamakan format data |
| `validate_data()` | memeriksa kualitas data |
| `transform_data()` | mengatur keseluruhan proses transformasi |

### Konsep pipeline transformation

```text
Raw Data
   |
   v
Create DataFrame
   |
   v
Clean Data
   |
   v
Standardize Data
   |
   v
Convert Data Types
   |
   v
Validate Data
   |
   v
Transformed Data
```

Dengan struktur modular, ketika ada perubahan aturan bisnis, kita tidak harus mengubah seluruh pipeline.

## 10. Data Transformation dalam Data Warehouse

Transformation bukan hanya membersihkan data. Dalam Data Engineering, transformation juga bisa mengubah struktur data agar sesuai dengan kebutuhan Data Warehouse.

Contohnya, API mengirimkan data transaksi:

| order_id | customer_name | product_name | quantity | price |
|----------|---------------|--------------|---------:|------:|
| 1 | Alice | Laptop | 1 | 10000000 |
| 2 | Bob | Mouse | 2 | 150000 |

Kita ingin mempersiapkannya menjadi Star Schema.

### Contoh target Star Schema

```text
fact_sales
----------
order_id · customer_key · product_key · quantity · total_amount

dim_customer
------------
customer_key · customer_name

dim_product
-----------
product_key · product_name · price
```

Dalam proses ini, transformation bisa meliputi:

1. mengidentifikasi business key,
2. memisahkan data customer dan product,
3. menghasilkan dimension records,
4. menghubungkan foreign key,
5. menghitung measure seperti total amount,
6. menyesuaikan data dengan target schema.

Contoh perhitungan:

```text
total_amount = quantity × price
```

**Catatan:** Tidak semua transformation harus dilakukan menggunakan Pandas. Bergantung pada arsitektur ETL/ELT, sebagian transformasi bisa dilakukan langsung menggunakan SQL di database atau data warehouse.

## 11. Best Practices Data Transformation

Praktik yang perlu dibiasakan sebagai calon Data Engineer:

| Best practice | Alasan |
|---------------|--------|
| Jangan mengubah raw data secara langsung | memungkinkan reprocessing |
| Pisahkan Extract dan Transform | separation of concerns |
| Gunakan function modular | mudah dipelihara |
| Tentukan business rules | menghindari kesalahan transformasi |
| Validasi sebelum Load | mencegah data invalid masuk database |
| Perhatikan data types | menjaga konsistensi schema |
| Catat jumlah row | monitoring data pipeline |
| Tangani invalid records | menghindari kehilangan data penting |
| Gunakan logging | memudahkan debugging dan monitoring |
| Buat unit tests | memastikan transformation berjalan sesuai ekspektasi |

### Monitoring jumlah data

```python
raw_count = len(raw_data)
clean_count = len(clean_data)
removed_count = raw_count - clean_count
```

Informasi ini membantu mengetahui perubahan jumlah data selama transformation. Dalam pipeline production, informasi tersebut sebaiknya dicatat menggunakan Python `logging`.

## Cheat Sheet

| Kebutuhan | Pandas |
|-----------|--------|
| JSON → tabel | `pd.DataFrame(data)` |
| Lihat struktur data | `df.info()`, `df.dtypes`, `df.shape` |
| Cek missing value | `df.isnull().sum()` |
| Hapus / isi missing value | `dropna()` / `fillna()` |
| Cek / hapus duplicate | `duplicated()` / `drop_duplicates()` |
| Rapikan string | `.str.strip()`, `.str.lower()`, `.str.title()` |
| Ubah ke angka | `astype()` / `pd.to_numeric(errors="coerce")` |
| Ubah ke tanggal | `pd.to_datetime()` |
| Ambil bagian tanggal | `.dt.year`, `.dt.month`, `.dt.day_name()` |
| Ratakan nested JSON | `pd.json_normalize()` |

Urutan transformation:

```text
Clean → Standardize → Convert types → Validate → Transformed data
```

# Meeting 31 — Extract Data

## Ringkasan
Memulai Project 2 (ETL pipeline) pada Tahap 1: Extraction. Mempelajari apa itu data extraction dan peran extractor, cara mengambil data dari REST API dengan `requests`, HTTP status code, membaca file CSV dan JSON, API pagination (page, offset, cursor), timeout, rate limiting dan exponential backoff, error handling, serta cara menyusun extractor yang reusable. Ditutup dengan gambaran arsitektur Extract Project 2 dan checklist standar extractor.

## 1. Apa Itu Data Extraction?

**Data Extraction** adalah proses mengambil data dari sumber eksternal untuk diproses lebih lanjut dalam ETL pipeline.

Dalam pekerjaan Data Engineer, sumber datanya bisa berasal dari:

- REST API
- CSV files
- JSON files
- database lain
- cloud storage

### Contoh kasus nyata
Sebuah perusahaan e-commerce ingin mengambil data transaksi dari API milik payment gateway setiap hari.

```text
Payment Gateway API
        ↓
   Source data
        ↓
Python Extractor
(mengambil data menggunakan HTTP request)
        ↓
    Raw Data
(hasil extraction, belum ditransformasi)
        ↓
Transform → Load PostgreSQL
```

**Hal penting:** Extractor bertugas **mengambil data saja**. Jangan mencampurkan proses cleaning atau transformasi ke dalam extractor.

## 2. Mengambil Data dari REST API

Kita menggunakan library Python `requests`.

**Kenapa `requests`?** Karena library ini mempermudah Python untuk berkomunikasi dengan server menggunakan HTTP.

```python
import requests

response = requests.get(
    "https://jsonplaceholder.typicode.com/posts"
)

print(response.status_code)
print(response.json())
```

Ada tiga konsep yang perlu dipahami.

### A. HTTP Request
Python mengirim permintaan kepada API.

### B. HTTP Response
Server mengembalikan respons kepada Python.

### C. JSON
Format data yang sering digunakan REST API untuk mengirimkan data.

Contoh response:

```json
{
    "userId": 1,
    "id": 1,
    "title": "My first post",
    "body": "Some content"
}
```

```text
Python (requests.get)
        ↓  HTTP request
      API Server
        ↓  HTTP response (status code + JSON)
Python (response.json())
```

## 3. Memahami HTTP Status Code

Saat mengambil data, jangan hanya memeriksa apakah kode berhasil dijalankan. Kita harus tahu apakah server memberikan respons yang benar.

| Status code | Arti |
|-------------|------|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

Dalam production pipeline, status code sangat penting untuk menentukan apakah proses extraction berhasil atau gagal.

Cara mudah membacanya berdasarkan angka pertama:

| Rentang | Kelompok | Contoh |
|---------|----------|--------|
| 2xx | sukses | 200, 201 |
| 4xx | kesalahan dari sisi client (request kita) | 400, 401, 403, 404, 429 |
| 5xx | kesalahan dari sisi server | 500 |

## 4. Reading CSV dan JSON

Selain API, extractor juga sering membaca file. Berikut implementasi yang perlu dikuasai.

### CSV
Menggunakan built-in module `csv`:

```python
import csv

def extract_csv(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        data = list(reader)
    return data
```

### JSON
Menggunakan built-in module `json`:

```python
import json

def extract_json(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        data = json.load(file)
    return data
```

### Perbedaan penting

| | CSV | JSON |
|---|-----|------|
| Bentuk data | tabular | terstruktur |
| Cara baca | umumnya per baris | bisa berupa object, array, nested object |
| Tipe nilai | default berupa string | mendukung string, number, boolean, null |
| Fungsi | `csv.DictReader()` | `json.load()` |

### Kenapa fungsi pakai `return`, bukan `print()`?
Karena hasil extraction harus bisa digunakan oleh proses berikutnya, yaitu **Transform**.

## 5. API Pagination

Ini salah satu konsep paling penting dalam API extraction.

**Pagination** adalah teknik mengambil data secara bertahap dalam beberapa request, karena API tidak selalu mengirim seluruh data sekaligus.

Misalnya sebuah API punya 1.000 records, tetapi membatasi response menjadi 100 records per request.

```text
Page 1  →  Record 1–100
Page 2  →  Record 101–200
Page 3  →  Record 201–300
...
```

Prosesnya berulang sampai tidak ada halaman berikutnya.

### Jenis pagination

**A. Page-based pagination.** API menerima nomor halaman.

```text
GET /posts?page=1
GET /posts?page=2
GET /posts?page=3
```

**B. Offset-based pagination.** API menggunakan `offset` dan `limit`.

```text
GET /posts?limit=100&offset=0
GET /posts?limit=100&offset=100
GET /posts?limit=100&offset=200
```

**C. Cursor-based pagination.** API memberikan `cursor` sebagai penanda posisi data berikutnya.

```text
GET /posts?cursor=abc123
GET /posts?cursor=def456
```

Cursor-based sering dipakai ketika dataset besar atau data terus berubah, karena lebih cocok untuk melanjutkan pengambilan berdasarkan posisi tertentu.

### Implementasi pagination
Kita pakai JSONPlaceholder yang mendukung parameter `_page` dan `_limit`.

```python
import requests

url = "https://jsonplaceholder.typicode.com/posts"

all_data = []
page = 1
limit = 10

while True:
    params = {
        "_page": page,
        "_limit": limit
    }

    response = requests.get(
        url,
        params=params,
        timeout=10
    )
    response.raise_for_status()

    data = response.json()

    if not data:
        break

    all_data.extend(data)
    page += 1

print(len(all_data))
```

Konsep yang perlu dipahami:

| Syntax | Fungsi |
|--------|--------|
| `params` | mengirim query parameters |
| `while True` | mengulang request |
| `if not data` | mendeteksi response kosong |
| `break` | menghentikan loop |
| `extend()` | menggabungkan records ke list |
| `page += 1` | pindah ke halaman berikutnya |

### `extend()` vs `append()`

```python
a = [1, 2]
a.append([3, 4])
# hasil: [1, 2, [3, 4]]
```

```python
a = [1, 2]
a.extend([3, 4])
# hasil: [1, 2, 3, 4]
```

Untuk menggabungkan records hasil pagination, biasanya kita pakai `extend()`.

## 6. Timeout

API tidak selalu merespons dengan cepat. Bayangkan pipeline mengirim request ke API, tetapi server tidak merespons selama 10 menit. Tanpa timeout, proses bisa menggantung terlalu lama.

**Timeout** digunakan untuk membatasi waktu tunggu request.

```python
response = requests.get(
    url,
    timeout=10
)
```

Artinya batas waktu 10 detik untuk request.

`requests` juga mendukung *connect timeout* dan *read timeout* secara terpisah:

```python
response = requests.get(
    url,
    timeout=(3, 10)
)
```

Artinya:

- 3 detik untuk membuat koneksi.
- 10 detik untuk menunggu data dari server setelah koneksi terbentuk.

Jika timeout terjadi, `requests` akan menghasilkan `requests.exceptions.Timeout`.

**Kenapa penting untuk Data Engineer?** Karena ETL pipeline harus punya batas waktu yang jelas agar tidak menghabiskan resource akibat request yang menggantung.

## 7. Rate Limiting

**Rate limiting** adalah pembatasan jumlah request yang boleh dikirim ke API dalam periode tertentu.

Contoh, sebuah API memberikan batas:

```text
100 requests per minute
```

Artinya client hanya boleh mengirim 100 request dalam satu menit. Kalau kita mengirim 200 request sekaligus, API bisa memberikan:

```text
429 Too Many Requests
```

### Cara menangani rate limiting
Salah satu cara sederhana adalah `time.sleep()`:

```python
import time

time.sleep(1)
```

Kode tersebut menghentikan eksekusi selama satu detik.

Namun, di production kita sebaiknya tidak selalu memakai fixed delay. Pendekatan yang lebih baik:

- periksa HTTP status code 429,
- perhatikan header `Retry-After` jika tersedia,
- tunggu sesuai instruksi server,
- gunakan **exponential backoff** jika diperlukan.

Contoh exponential backoff:

| Percobaan | Waktu tunggu |
|-----------|--------------|
| 1 | 1 detik |
| 2 | 2 detik |
| 3 | 4 detik |
| 4 | 8 detik |

Tujuannya menghindari request berulang secara agresif ketika server sedang membatasi akses.

## 8. API Error Handling

Sebelumnya kita sudah memakai pola ini:

```python
try:
    response = requests.get(url, timeout=10)
    response.raise_for_status()
except requests.RequestException as e:
    print(f"Request failed: {e}")
```

Sekarang kita pahami beberapa jenis error yang mungkin terjadi.

| Exception | Penyebab |
|-----------|----------|
| `Timeout` | request melewati batas waktu |
| `ConnectionError` | gagal terhubung ke server |
| `HTTPError` | HTTP status menunjukkan error |
| `RequestException` | base exception dari Requests |

Di production, error tidak boleh hanya diabaikan. Pipeline perlu tahu:

- request mana yang gagal,
- endpoint mana yang bermasalah,
- apakah kegagalan bersifat sementara atau permanen,
- apakah aman untuk di-retry.

Logging dan retry akan didalami pada **Pertemuan 34**.

## 9. Struktur Extractor yang Lebih Reusable

Kita tidak ingin menulis kode request berulang kali untuk setiap endpoint. Kita bisa membuat fungsi yang reusable:

```python
import requests

def extract_api(url, params=None):
    try:
        response = requests.get(
            url,
            params=params,
            timeout=(3, 10)
        )
        response.raise_for_status()
        return response.json()

    except requests.RequestException as e:
        print(f"Extraction failed: {e}")
        raise
```

### Kenapa `raise` lagi setelah menangkap exception?
Karena fungsi extractor tidak seharusnya menyembunyikan kegagalan. Pemanggil fungsi perlu tahu bahwa extraction gagal, supaya pipeline tidak melanjutkan proses dengan data yang tidak lengkap.

Ini adalah dasar dari **error propagation**.

## 10. Gambaran Arsitektur Extract Project 2

```text
Public API
JSONPlaceholder
      ↓
┌──────────────────────────────┐
│           EXTRACT            │
│                              │
│  API Request     File Reader │
│  (requests)      (CSV/JSON)  │
│                              │
│  Pagination · Timeout ·      │
│  Error Handling              │
└──────────────┬───────────────┘
               ↓
           Raw Data
(list of dictionaries / JSON records)
               ↓
   Pertemuan 32 — Transform
   Pandas · Cleaning · Data Quality
```

## 11. Standar Extractor

Sebelum menganggap extractor layak dipakai di project, pastikan:

- [ ] Menggunakan timeout.
- [ ] Memeriksa HTTP status.
- [ ] Menangani request errors.
- [ ] Memahami pagination.
- [ ] Tidak melewati rate limit API.
- [ ] Memisahkan extraction dari transformation.
- [ ] Menghasilkan raw data yang bisa digunakan tahap berikutnya.

### Referensi dokumentasi resmi
- [Requests Documentation](https://requests.readthedocs.io/)
- [Python CSV Documentation](https://docs.python.org/3/library/csv.html)
- [Python JSON Documentation](https://docs.python.org/3/library/json.html)

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| Extractor | hanya mengambil data, tanpa cleaning atau transformasi |
| `requests.get` + `raise_for_status()` | kirim request dan pastikan status tidak error |
| `csv.DictReader` / `json.load` | membaca file CSV / JSON |
| Pagination | ambil data bertahap: page, offset, atau cursor |
| `extend()` vs `append()` | `extend` menambah elemen satu per satu, `append` menambah satu item (bisa berupa list) |
| Timeout | batas waktu tunggu, `timeout=(3, 10)` untuk connect dan read |
| Rate limit (429) | tunggu sesuai `Retry-After`, atau exponential backoff |
| `raise` di extractor | kegagalan harus diteruskan ke pemanggil |

Alur Project 2:

```text
Extract (tahap 1)  →  Transform (P32)  →  Load ke PostgreSQL
```

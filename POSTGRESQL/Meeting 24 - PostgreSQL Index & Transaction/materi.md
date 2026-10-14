# Meeting 24 — Index & Transaction

## Ringkasan
Mempelajari index pada PostgreSQL (konsep, B-tree, composite index, UNIQUE index, index untuk foreign key, dan pemeliharaannya) untuk mempercepat query tertentu, serta transaction (`BEGIN`, `COMMIT`, `ROLLBACK`, prinsip ACID, simulasi transfer uang, dan concurrent updates) untuk menjaga konsistensi data. Ditutup dengan penerapan keduanya dalam pekerjaan Data Engineer.

---

# BAGIAN A — INDEX

## 1. Konsep: Apa Itu Index?

Misalnya kita ingin mencari transaksi berdasarkan `account_id` pada tabel yang memiliki 1 juta baris. PostgreSQL mungkin perlu memeriksa banyak baris satu per satu (**Sequential Scan**).

Dengan index yang sesuai, PostgreSQL bisa menggunakan struktur pencarian untuk menemukan kandidat baris tanpa harus memeriksa seluruh tabel.

**Catatan:** Index tidak selalu membuat query lebih cepat. Sequential Scan justru lebih efisien ketika tabel kecil atau query mengambil sebagian besar baris.

### Kenapa index diperlukan?
Index membantu mengurangi pekerjaan untuk query tertentu. Namun, index bukan salinan lengkap tabel yang gratis untuk dibuat.

### Tiga trade-off utama

| Aspek | Penjelasan |
|-------|------------|
| Read performance | pencarian tertentu dapat lebih cepat |
| Write performance | `INSERT`, `UPDATE`, dan `DELETE` perlu memelihara index terkait |
| Storage | index membutuhkan ruang penyimpanan tambahan |

### Kapan index layak dipertimbangkan
- kolom yang sering dipakai pada `WHERE`
- kolom yang sering digunakan untuk `JOIN`
- kolom yang sering digunakan untuk pengurutan (`ORDER BY`)
- kolom yang digunakan untuk pencarian range, seperti `created_at >= ...`
- kolom yang perlu memenuhi constraint `UNIQUE`

### Kapan tidak perlu membuat index
- tabel sangat kecil
- kolom jarang digunakan untuk pencarian
- kolom memiliki banyak perubahan dan index tidak memberikan manfaat berarti
- index yang sama atau tumpang tindih sudah tersedia
- query tetap membaca hampir semua baris tabel

## 2. Konsep: B-tree

B-tree adalah jenis index default PostgreSQL. B-tree cocok untuk perbandingan kesetaraan dan rentang nilai, misalnya:

```sql
WHERE account_id = '...'
WHERE amount > 100000
WHERE created_at >= '2026-01-01'
ORDER BY created_at
```

B-tree menjaga key dalam struktur yang terurut, sehingga PostgreSQL bisa menavigasi index tanpa memeriksa setiap key secara berurutan.

## 3. Syntax: Membuat Index

### Langkah 1 — Buat tabel transaksi

```sql
CREATE TABLE finance_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    category_id UUID,
    transaction_type VARCHAR(10) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Langkah 2 — Buat index

```sql
CREATE INDEX idx_finance_transactions_account_id
ON finance_transactions (account_id);
```

| Bagian | Arti |
|--------|------|
| `CREATE INDEX` | membuat index non-unik |
| `idx_finance_transactions_account_id` | nama index |
| `ON finance_transactions` | tabel target |
| `(account_id)` | kolom yang menjadi key index |

### Langkah 3 — Gunakan query yang relevan

```sql
SELECT id, amount, created_at
FROM finance_transactions
WHERE account_id = '550e8400-e29b-41d4-a716-446655440000';
```

Index pada `account_id` berpotensi membantu query ini. Tetapi kalau belum ada data atau tabel hanya memiliki sedikit baris, PostgreSQL mungkin tetap memilih Sequential Scan.

### Langkah 4 — Evaluasi query

```sql
EXPLAIN
SELECT id, amount, created_at
FROM finance_transactions
WHERE account_id = '550e8400-e29b-41d4-a716-446655440000';
```

`EXPLAIN` menampilkan rencana eksekusi yang dipilih PostgreSQL, bukan menjalankan query untuk mengambil hasil datanya.

Contoh elemen yang bisa muncul:

| Elemen | Arti |
|--------|------|
| Seq Scan | membaca tabel secara berurutan |
| Index Scan | menggunakan index untuk menemukan baris |
| Bitmap Index Scan | menggunakan index untuk mengumpulkan lokasi baris yang relevan |
| cost | estimasi biaya internal planner, bukan waktu dalam milidetik |

## 4. Composite Index — Index dengan Banyak Kolom

Misalnya sebuah dashboard menampilkan transaksi sebuah akun dari waktu terbaru:

```sql
SELECT id, amount, created_at
FROM finance_transactions
WHERE account_id = '550e8400-e29b-41d4-a716-446655440000'
ORDER BY created_at DESC
LIMIT 20;
```

Kita bisa mempertimbangkan composite index:

```sql
CREATE INDEX idx_finance_transactions_account_created
ON finance_transactions (account_id, created_at DESC);
```

Index ini mengurutkan key berdasarkan `account_id`, kemudian `created_at` di dalam kelompok akun yang sama.

### Mengapa urutan kolom penting
B-tree composite index umumnya paling efektif untuk kondisi yang menggunakan kolom paling kiri terlebih dahulu.

Index `(account_id, created_at)` bisa membantu:

- `WHERE account_id = ...`
- `WHERE account_id = ... AND created_at >= ...`
- filter akun dan pengurutan waktu yang sesuai

Tetapi index tersebut belum tentu efektif untuk query yang hanya mencari `created_at` tanpa filter pada `account_id`.

Prinsip ini sering disebut **leftmost-prefix principle**.

**Catatan:** Jangan membuat composite index secara otomatis untuk semua kombinasi kolom. Mulai dari query nyata, lalu ukur manfaatnya.

## 5. UNIQUE Index dan Index untuk Foreign Key

### Pertama: UNIQUE constraint

```sql
ALTER TABLE finance_transactions
ADD CONSTRAINT uq_transaction_external_id
UNIQUE (description);
```

Constraint `UNIQUE` menegakkan aturan integritas, dan PostgreSQL umumnya membuat unique B-tree index untuk mendukungnya. Gunakan constraint jika ingin melarang nilai duplikat, bukan sekadar mempercepat pencarian.

### Kedua: foreign key
PostgreSQL secara otomatis mengindeks kolom primary key atau unique key yang menjadi target referensi. Namun, PostgreSQL **tidak** otomatis membuat index pada kolom foreign key di tabel anak.

```sql
CREATE INDEX idx_finance_transactions_account_id
ON finance_transactions (account_id);
```

Index seperti ini dapat membantu pencarian transaksi per akun dan pemeriksaan terkait ketika akun yang direferensikan dihapus atau diperbarui. Tetap evaluasi kebutuhan berdasarkan query dan pola perubahan data.

## 6. Memelihara Index

Melihat daftar index pada tabel tertentu:

```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'finance_transactions';
```

Menghapus index yang tidak diperlukan:

```sql
DROP INDEX idx_finance_transactions_account_id;
```

**Perhatian:** Jangan menghapus index yang dibutuhkan constraint atau aplikasi tanpa memeriksa dependensinya. Menghapus index yang mendukung constraint bisa gagal atau berdampak pada integritas data, tergantung index dan dependensinya.

Untuk sistem yang sedang aktif menerima traffic, PostgreSQL menyediakan:

```sql
CREATE INDEX CONCURRENTLY idx_example
ON finance_transactions (account_id);
```

`CONCURRENTLY` dirancang agar pembuatan index mengurangi pemblokiran operasi tulis biasa dibandingkan pembuatan index standar. Namun, prosesnya lebih kompleks dan bisa lebih lama.

Batasan penting:

- tidak boleh dijalankan di dalam transaction block eksplisit
- bisa gagal dan meninggalkan index invalid yang perlu diperiksa
- tetap memerlukan sumber daya dan pemantauan

---

# BAGIAN B — TRANSACTION

## 7. Konsep: Apa Itu Transaction?

Transaction adalah sekumpulan operasi database yang diperlakukan sebagai satu unit kerja.

Contoh paling mudah adalah transfer uang dari satu akun ke akun lain:

- Akun A memiliki Rp1.000.000.
- Akun B memiliki Rp500.000.
- Transfer Rp200.000 dari A ke B.

Hasil yang diharapkan:

- Akun A menjadi Rp800.000.
- Akun B menjadi Rp700.000.

Masalahnya, transfer memerlukan lebih dari satu operasi. Kalau saldo A berkurang tetapi proses gagal sebelum saldo B bertambah, data menjadi tidak konsisten.

Transaction membantu memastikan bahwa perubahan yang menjadi satu kesatuan pekerjaan dapat disimpan bersama-sama atau dibatalkan bersama-sama.

## 8. Syntax Dasar Transaction

| Command | Fungsi |
|---------|--------|
| `BEGIN;` | memulai transaction eksplisit |
| `COMMIT;` | mengakhiri transaction dan menetapkan perubahan agar disimpan |
| `ROLLBACK;` | membatalkan perubahan yang belum di-commit dalam transaction aktif |

Ketiganya merupakan perintah transaction control yang dikenal di SQL. Perilaku rinci seperti isolation level dan beberapa fasilitas transaction berbeda antar-DBMS.

Contoh sederhana:

```sql
BEGIN;

UPDATE finance_transactions
SET amount = 150000
WHERE id = '550e8400-e29b-41d4-a716-446655440000';

COMMIT;
```

Jika semua operasi berhasil dan `COMMIT` sukses, perubahan akan disimpan.

## 9. ACID — Empat Prinsip Penting

ACID adalah empat sifat yang membantu keandalan transaction.

| Huruf | Prinsip | Penjelasan |
|-------|---------|------------|
| **A** | Atomicity — semua atau tidak sama sekali | Jika debit berhasil tetapi kredit gagal, seluruh perubahan transaction harus dibatalkan. |
| **C** | Consistency — menjaga aturan data | Transaction yang berhasil harus membawa database dari satu keadaan valid ke keadaan valid lainnya, sesuai constraint dan aturan bisnis yang ditegakkan. |
| **I** | Isolation — mengendalikan interaksi antar-transaction | Transaction yang berjalan bersamaan mengikuti aturan isolation yang ditetapkan. Tingkat isolasi menentukan anomali apa yang mungkin terjadi. |
| **D** | Durability — perubahan yang di-commit bertahan | Setelah `COMMIT` sukses, PostgreSQL dirancang menjaga perubahan tersebut melewati kegagalan sistem, sesuai konfigurasi durability dan mekanisme penyimpanannya. |

## 10. Praktik: Membuat Tabel Akun

Untuk simulasi transfer, kita gunakan tabel khusus agar tidak tercampur dengan tabel transaksi.

```sql
CREATE TABLE demo_accounts (
    account_id INTEGER PRIMARY KEY,
    account_name VARCHAR(50) NOT NULL,
    balance NUMERIC(14, 2) NOT NULL CHECK (balance >= 0)
);
```

Masukkan data awal:

```sql
INSERT INTO demo_accounts (account_id, account_name, balance)
VALUES
    (1, 'Account A', 1000000),
    (2, 'Account B', 500000);
```

Lihat saldo:

```sql
SELECT *
FROM demo_accounts
ORDER BY account_id;
```

Hasil awal yang diharapkan:

| account_id | account_name | balance |
|------------|--------------|---------|
| 1 | Account A | 1.000.000,00 |
| 2 | Account B | 500.000,00 |

**Catatan:** Jika `INSERT` ini diulang, primary key akan menolak duplikasi ID. Karena itu, persiapan dilakukan satu kali, atau data latihan dibersihkan terlebih dahulu sebelum diulang.

## 11. Simulasi Transaction: Transfer Uang

Kita gunakan dua operasi `UPDATE` dalam satu transaction.

```sql
BEGIN;

UPDATE demo_accounts
SET balance = balance - 200000
WHERE account_id = 1;

UPDATE demo_accounts
SET balance = balance + 200000
WHERE account_id = 2;

COMMIT;
```

Jika kedua update berhasil, saldo akhirnya menjadi:

| Akun | Saldo awal | Perubahan | Saldo akhir |
|------|-----------|-----------|-------------|
| A | 1.000.000 | -200.000 | 800.000 |
| B | 500.000 | +200.000 | 700.000 |

Contoh ini mengasumsikan kedua akun ada dan jumlah transfer valid. Untuk implementasi yang lebih kuat, kita perlu:

- memeriksa saldo mencukupi,
- memastikan setiap update mengenai tepat satu akun, dan
- menangani kondisi ketika operasi gagal.

### Uji ROLLBACK

```sql
BEGIN;

UPDATE demo_accounts
SET balance = balance - 100000
WHERE account_id = 1;

SELECT *
FROM demo_accounts
ORDER BY account_id;

ROLLBACK;
```

Sesudah `ROLLBACK`, jalankan lagi:

```sql
SELECT *
FROM demo_accounts
ORDER BY account_id;
```

Saldo harus kembali ke kondisi sebelum transaction kedua dimulai.

**Catatan pgAdmin:** Jika statement dijalankan melalui Query Tool, pastikan statement dieksekusi pada sesi yang sama. Perubahan yang belum di-commit juga bisa membuat sesi lain melihat hasil berbeda, bergantung pada isolation level.

## 12. Transaction Gagal: Kenapa Harus Rollback?

Perhatikan transaction berikut:

```sql
BEGIN;

UPDATE demo_accounts
SET balance = balance - 200000
WHERE account_id = 1;

UPDATE demo_accounts
SET balance = balance + 200000
WHERE account_id = 999;

COMMIT;
```

Masalahnya, akun 999 tidak ada. Statement kedua berjalan tanpa memperbarui akun mana pun.

PostgreSQL tidak otomatis menganggap setiap `UPDATE` yang mengenai nol baris sebagai error. Akibatnya, transaction ini bisa tetap di-commit meskipun transfer tidak benar-benar lengkap.

Ini misconception yang perlu dihindari: **transaction bukan pengganti validasi aturan bisnis.**

Implementasi yang lebih kuat perlu memeriksa jumlah baris yang diperbarui dan menolak transfer jika debit atau kredit tidak tepat. Dalam prosedur atau aplikasi, gunakan error handling dan lakukan rollback saat pemeriksaan gagal.

## 13. Transaction dan Concurrent Updates

Bayangkan dua proses berjalan hampir bersamaan:

- Proses A ingin mengurangi saldo akun sebesar Rp200.000.
- Proses B ingin mengurangi saldo akun yang sama sebesar Rp300.000.

Kalau kedua proses membaca saldo lama, menghitung nilai baru di aplikasi, lalu menulis hasilnya tanpa kontrol yang tepat, salah satu perubahan bisa menimpa yang lain.

Pendekatan yang lebih aman untuk pengurangan saldo adalah melakukan update secara atomik di database, misalnya:

```sql
UPDATE demo_accounts
SET balance = balance - 200000
WHERE account_id = 1
  AND balance >= 200000;
```

Statement ini hanya mengurangi saldo jika kondisi saldo mencukupi ketika baris diproses.

Namun, aplikasi masih harus memeriksa jumlah baris yang diperbarui. Nol baris berarti akun tidak ditemukan atau saldo tidak mencukupi, dan keduanya perlu ditangani dengan benar.

Untuk transfer yang melibatkan dua akun, kedua update juga perlu dijalankan dalam satu transaction. Ini adalah fondasi concurrency control pada aplikasi keuangan.

---

# BAGIAN C — INDEX + TRANSACTION DALAM DATA ENGINEERING

## 14. Kapan Materi Ini Dipakai di Dunia Kerja?

| Skenario | Peran index | Peran transaction |
|----------|-------------|-------------------|
| Extract transaksi harian | membantu filter berdasarkan waktu atau key jika index sesuai | menjaga konsistensi operasi pada source database |
| Load ke tabel staging | membantu pencarian dan validasi tertentu | mengelompokkan insert atau perubahan agar dapat di-commit atau dibatalkan |
| Upsert data pelanggan | mendukung lookup dan unique constraint | menjaga rangkaian perubahan tetap konsisten |
| Finance pipeline | membantu query berdasarkan akun dan waktu | menjaga transfer dan perubahan saldo |
| Data warehouse | membantu query tertentu, tergantung desain tabel | mengatur transaksi saat proses load atau transformasi |

Satu hal penting: jangan menganggap semua ETL harus dibungkus dalam satu transaction raksasa. Transaction yang terlalu panjang bisa menahan lock, memperpanjang penggunaan resource, dan menghambat proses lain. Untuk pipeline besar, desain batch, checkpoint, idempotency, dan strategi retry juga penting.

Index juga bukan solusi universal untuk query analitik. Pada data warehouse dengan scan besar, desain tabel, partitioning, distribusi data, dan strategi penyimpanan bisa lebih berpengaruh.

---

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| `CREATE INDEX` | membuat index non-unik pada kolom tertentu |
| B-tree | tipe index default, cocok untuk `=`, range, dan `ORDER BY` |
| Composite index | urutan kolom penting (leftmost-prefix principle) |
| `EXPLAIN` | melihat rencana eksekusi tanpa menjalankan query |
| `CREATE INDEX CONCURRENTLY` | membuat index pada sistem aktif, tidak boleh di dalam transaction block |
| `DROP INDEX` | menghapus index, periksa dependensi constraint dulu |
| `BEGIN` / `COMMIT` / `ROLLBACK` | memulai / menyimpan / membatalkan transaction |
| ACID | Atomicity, Consistency, Isolation, Durability |
| `UPDATE ... AND balance >= x` | pengurangan saldo atomik, cek jumlah baris yang berubah |

    
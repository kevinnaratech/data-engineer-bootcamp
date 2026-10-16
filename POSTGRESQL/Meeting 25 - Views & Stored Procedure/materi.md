# Meeting 25 — Views, Materialized Views, Functions & Stored Procedures

## Ringkasan
Mempelajari objek database yang dipakai untuk menyederhanakan dan menyeragamkan logic query di PostgreSQL: View (menyimpan definisi query), Materialized View (menyimpan hasil query dan perlu di-refresh), Function (menjalankan logic dan mengembalikan nilai), dan Stored Procedure (menjalankan rangkaian operasi dengan `CALL`). Ditutup dengan koneksi ke Data Engineering: kapan memakai masing-masing, dan perbedaannya dengan ETL dan orchestration tool seperti Airflow.

---

# Bagian 1 — Views

## 1.1 Konsep: Apa Itu View?

Bayangkan punya tabel `transactions` yang berisi jutaan transaksi. Setiap kali ingin membuat laporan pengeluaran bulanan, harus menulis query seperti ini:

```sql
SELECT
    account_id,
    DATE_TRUNC('month', transaction_date) AS month,
    SUM(amount) AS total_expense
FROM transactions
WHERE transaction_type = 'expense'
GROUP BY
    account_id,
    DATE_TRUNC('month', transaction_date);
```

Query ini benar. Tapi kalau dipakai berulang kali oleh dashboard, laporan, dan aplikasi lain, ada beberapa masalah:

- Query panjang harus ditulis berulang kali.
- Perubahan logic harus dilakukan di banyak tempat.
- Risiko laporan menggunakan definisi perhitungan yang berbeda semakin besar.

**View** menyelesaikan masalah tersebut dengan menyimpan definisi query sebagai objek database.

View biasa **tidak** menyimpan hasil query secara permanen. Saat diakses, PostgreSQL menggunakan definisi query-nya untuk menghasilkan data.

**Analogi:** view adalah jendela ke data yang ada di tabel lain.

### Kapan digunakan?
- Membuat laporan yang sering digunakan.
- Menyederhanakan query kompleks.
- Menyediakan kolom tertentu tanpa membuka seluruh kolom tabel.
- Menyeragamkan definisi metrik yang dipakai oleh beberapa konsumen data.

### Kapan tidak digunakan?
Jangan menganggap view otomatis mempercepat query. View biasa umumnya tidak menyimpan hasil perhitungannya. Kalau query di dalam view mahal, akses ke view tersebut juga bisa mahal.

## 1.2 Syntax PostgreSQL

Anggap tabel `transactions` memiliki kolom berikut:

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID` | ID transaksi |
| `account_id` | `UUID` | ID akun |
| `amount` | `NUMERIC` | nominal transaksi |
| `transaction_type` | `TEXT` | `income` atau `expense` |
| `transaction_date` | `TIMESTAMPTZ` | waktu transaksi |
| `category_id` | `UUID` | kategori transaksi |

Membuat view pengeluaran:

```sql
CREATE VIEW expense_transactions AS
SELECT
    id,
    account_id,
    amount,
    transaction_date,
    category_id
FROM transactions
WHERE transaction_type = 'expense';
```

Penjelasan:

| Bagian | Arti |
|--------|------|
| `CREATE VIEW expense_transactions` | membuat objek view |
| `AS` | mendefinisikan query yang mendasari view |
| `SELECT` | memilih kolom yang ingin ditampilkan |
| `WHERE` | membatasi data yang termasuk ke dalam view |

Setelah dibuat, view bisa digunakan seperti tabel biasa:

```sql
SELECT *
FROM expense_transactions;
```

Atau digabungkan dengan query lain:

```sql
SELECT
    account_id,
    SUM(amount) AS total_expense
FROM expense_transactions
GROUP BY account_id;
```

Perhatikan: tidak perlu menulis ulang kondisi `transaction_type = 'expense'`.

**Best practice:** gunakan nama view yang menjelaskan maknanya, dan jangan sembarangan memakai `SELECT *` di definisi view untuk objek yang akan dipakai jangka panjang. Memilih kolom secara eksplisit membuat kontrak data lebih jelas.

### SQL Standard vs PostgreSQL
`CREATE VIEW` merupakan fitur SQL Standard. PostgreSQL mendukungnya dengan berbagai kemampuan tambahan.

---

# Bagian 2 —    rialized View

## 2.1 Konsep

Sekarang bayangkan laporan pengeluaran bulanan harus menghitung agregasi dari puluhan juta transaksi setiap kali dashboard dibuka.

View biasa masih perlu menjalankan query berdasarkan data sumber. Untuk workload reporting tertentu, kita bisa menyimpan hasil query tersebut menggunakan **materialized view**.

```text
Tabel transaksi
(data operasional yang terus berubah)
        ↓
Query agregasi
(GROUP BY bulan, akun, dan kategori)
        ↓
Materialized View
(hasil agregasi disimpan dan bisa dibaca kembali)
```

Trade-off utamanya:

- Pembacaan laporan bisa lebih cepat karena hasilnya sudah disimpan.
- Hasil tersebut bisa menjadi *stale* (tidak terbaru).
- Hasil harus diperbarui dengan mekanisme *refresh*.
- Penyimpanan tambahan diperlukan.

Jadi, materialized view bukan sekadar view yang lebih bagus, menukar kebutuhan komputasi saat membaca dengan biaya penyimpanan dan pembaruan data.

## 2.2 Syntax

Membuat laporan pengeluaran bulanan:

```sql
CREATE MATERIALIZED VIEW monthly_expense_summary AS
SELECT
    account_id,
    DATE_TRUNC(
        'month',
        transaction_date
    ) AS month,
    SUM(amount) AS total_expense,
    COUNT(*) AS transaction_count
FROM transactions
WHERE transaction_type = 'expense'
GROUP BY
    account_id,
    DATE_TRUNC('month', transaction_date);
```

Saat perintah ini pertama kali dijalankan, PostgreSQL menghitung query dan menyimpan hasilnya.

Membaca hasilnya:

```sql
SELECT *
FROM monthly_expense_summary
ORDER BY month DESC;
```

Misalnya setelah itu ada transaksi pengeluaran baru. Jangan berasumsi materialized view langsung ikut berubah. Untuk memperbarui hasilnya:

```sql
REFRESH MATERIALIZED VIEW monthly_expense_summary;
```

PostgreSQL akan menghitung ulang hasil query dan memperbarui materialized view tersebut.

### Bagaimana jika laporan harus tetap bisa dibaca saat refresh?
PostgreSQL mendukung:

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY monthly_expense_summary;
```

Ada syarat penting: materialized view harus memiliki `UNIQUE` index yang memenuhi persyaratan PostgreSQL, antara lain mencakup seluruh baris dan menggunakan kolom biasa (bukan partial index atau expression index). Materialized view juga harus sudah terisi.

Contohnya:

```sql
CREATE UNIQUE INDEX
    uq_monthly_expense_summary
ON monthly_expense_summary (
    account_id,
    month
);
```

Index tersebut masuk akal jika kombinasi akun dan bulan memang unik dalam hasil agregasi.

### Kapan digunakan?
- Laporan agregasi berat yang sering dibaca.
- Dashboard analitik dengan toleransi keterlambatan pembaruan data.
- Ringkasan data untuk proses reporting.

Jangan otomatis memilih materialized view untuk semua laporan. Jika datanya kecil, query sederhana mungkin sudah cukup.

**Catatan PostgreSQL:** `CREATE MATERIALIZED VIEW`, `REFRESH MATERIALIZED VIEW`, dan mekanisme `CONCURRENTLY` merupakan kemampuan PostgreSQL yang tidak portabel secara langsung ke semua DBMS.

---

# Bagian 3 — Functions

## 3.1 Konsep

Function adalah objek database yang menjalankan logic dan mengembalikan nilai.

Contohnya, kita ingin menghitung total pengeluaran suatu akun. Daripada setiap aplikasi menulis ulang rumus, kita bisa mendefinisikannya sebagai function.

Di PostgreSQL, function dapat dipanggil dalam query SQL, bergantung pada tipe nilai yang dikembalikan.

## 3.2 Membuat Function Sederhana

Function untuk menghitung jumlah pengeluaran berdasarkan akun:

```sql
CREATE OR REPLACE FUNCTION
    get_total_expense(p_account_id UUID)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT COALESCE(SUM(amount), 0)
    FROM transactions
    WHERE account_id = p_account_id
      AND transaction_type = 'expense';
$$;
```

Penjelasan bagian penting:

| Bagian | Arti |
|--------|------|
| `CREATE OR REPLACE FUNCTION` | membuat function atau mengganti definisinya |
| `p_account_id UUID` | parameter masukan dengan tipe `UUID` |
| `RETURNS NUMERIC` | function mengembalikan satu nilai numerik |
| `LANGUAGE SQL` | isi function menggunakan SQL |
| `COALESCE(SUM(amount), 0)` | mengembalikan nol jika tidak ada transaksi yang memenuhi kondisi, bukan `NULL` |

Memanggil function:

```sql
SELECT get_total_expense(
    'ae53b055-f829-4724-a873-dc6890667667'::UUID
);
```

Ganti UUID contoh tersebut dengan `account_id` yang benar-benar ada di database lu.

### Kenapa function ini berguna?
Logic perhitungan disimpan di satu tempat. Kalau definisi perhitungan berubah, function bisa diperbarui sehingga duplikasi logic berkurang.

### Catatan penting
Function ini menghitung ulang data setiap kali dipanggil. Kalau function dipanggil untuk ribuan akun secara terpisah, pendekatan itu belum tentu seefisien satu query agregasi dengan `GROUP BY`.

Untuk mengambil total pengeluaran semua akun, query seperti ini biasanya lebih tepat:

```sql
SELECT
    account_id,
    SUM(amount) AS total_expense
FROM transactions
WHERE transaction_type = 'expense'
GROUP BY account_id;
```

Jangan menggunakan function hanya karena terlihat lebih rapi. Pilih bentuk query sesuai kebutuhan dan pola akses datanya.

---

# Bagian 4 — Stored Procedure

## 4.1 Konsep

Stored procedure adalah objek database untuk menjalankan serangkaian operasi.

Misalnya, di aplikasi finance, proses memindahkan uang dari satu akun ke akun lain bisa melibatkan:

1. Memastikan saldo sumber mencukupi.
2. Mengurangi saldo akun sumber.
3. Menambah saldo akun tujuan.
4. Mencatat transaksi debit dan kredit.

Kalau salah satu langkah gagal, perubahan yang tidak konsisten tidak boleh dibiarkan.

Stored procedure bisa menjadi tempat untuk mengenkapsulasi operasi tersebut. Namun, procedure sendiri tidak otomatis menjamin seluruh operasi aman. Tetap perlu transaksi, constraint, validasi, dan strategi locking yang benar.

## 4.2 Function vs Stored Procedure

| Aspek | Function | Procedure |
|-------|----------|-----------|
| Pemanggilan | `SELECT` untuk function yang sesuai | `CALL` |
| Hasil | dapat mengembalikan nilai atau tabel | dapat menggunakan parameter `OUT`/`INOUT` |
| Tujuan umum | perhitungan dan transformasi yang dapat dipakai dalam query | menjalankan rangkaian operasi |
| Kontrol transaksi | tidak dapat melakukan `COMMIT`/`ROLLBACK` secara bebas di dalam function | dapat melakukan kontrol transaksi dalam kondisi pemanggilan yang diizinkan |
| SQL Standard | ya | ya, dengan perbedaan implementasi antar-DBMS |

PostgreSQL mendukung function dan procedure. Bahasa prosedural seperti PL/pgSQL sangat terkait dengan PostgreSQL dan tidak selalu portabel ke database lain.

## 4.3 Contoh Procedure

Kita mulai dari contoh aman yang hanya melakukan satu operasi: mencatat sebuah event ke tabel log.

Buat tabel log terlebih dahulu:

```sql
CREATE TABLE finance_audit_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

Kemudian buat procedure:

```sql
CREATE OR REPLACE PROCEDURE
    log_finance_event(p_message TEXT)
LANGUAGE SQL
AS $$
    INSERT INTO finance_audit_log (event_message)
    VALUES (p_message);
$$;
```

Panggil procedure:

```sql
CALL log_finance_event(
    'Monthly expense report generated'
);
```

Verifikasi hasilnya:

```sql
SELECT *
FROM finance_audit_log
ORDER BY id DESC;
```

Contoh ini sederhana, tetapi memperlihatkan perbedaan konsepnya: procedure dipanggil untuk **menjalankan operasi**, bukan untuk memperoleh nilai hasil perhitungan melalui `SELECT`.

### Bagaimana dengan COMMIT dan ROLLBACK?
Ini nyambung ke Pertemuan 24 (Transaction).

Procedure PostgreSQL dapat melakukan kontrol transaksi dalam kondisi tertentu, tetapi tidak ketika `CALL` dijalankan di dalam transaction block eksplisit. Untuk transaksi bisnis yang membutuhkan konsistensi, jangan memindahkan seluruh tanggung jawab transaksi ke procedure tanpa memahami aturan tersebut.

---

# Bagian 5 — Koneksi ke Data Engineering

```text
PostgreSQL sebagai source database
(data transaksi operasional dengan constraints dan relasi yang tepat)
        ↓
ETL / ELT pipeline
(ekstraksi data dan transformasi terjadwal, misalnya dengan Python dan Airflow)
        ↓
Reporting dan analytics
(view menyediakan interface query yang konsisten;
 materialized view menyimpan hasil agregasi yang perlu diperbarui)
```

Keputusan penting dalam praktik Data Engineering:

- Gunakan **view** untuk menyederhanakan akses ke data dan menyeragamkan definisi query.
- Gunakan **materialized view** jika hasil yang disimpan memang memberikan manfaat untuk pola baca tertentu.
- Gunakan **function** ketika logic perlu dipanggil ulang di database dan cocok dieksekusi sebagai function.
- Gunakan **procedure** ketika proses operasional membutuhkan rangkaian perintah database yang terenkapsulasi.
- Untuk transformasi analitik berskala besar, pertimbangkan apakah logic lebih tepat dijalankan di warehouse atau pipeline daripada membebani production database.

**Satu hal yang perlu dipahami:** view bukan pengganti ETL, dan stored procedure bukan pengganti orchestration tool seperti Airflow. View dan procedure bekerja di dalam database, sedangkan Airflow mengatur kapan task dijalankan, dependensi antar-task, retry, serta pemantauan eksekusi.

---

## Cheat Sheet

| Objek | Menyimpan hasil? | Dipanggil dengan | Fungsi utama |
|-------|------------------|------------------|--------------|
| View | tidak (hanya definisi query) | `SELECT ... FROM view` | menyederhanakan dan menyeragamkan query |
| Materialized View | ya (perlu `REFRESH`) | `SELECT ... FROM mat_view` | mempercepat pembacaan agregasi berat |
| Function | tidak | `SELECT fungsi(...)` | logic yang mengembalikan nilai |
| Procedure | tidak | `CALL prosedur(...)` | menjalankan rangkaian operasi |

| Command | Fungsi |
|---------|--------|
| `CREATE VIEW` | membuat view |
| `CREATE MATERIALIZED VIEW` | membuat materialized view |
| `REFRESH MATERIALIZED VIEW` | memperbarui hasil materialized view |
| `REFRESH MATERIALIZED VIEW CONCURRENTLY` | refresh tanpa memblokir pembacaan (butuh `UNIQUE` index) |
| `CREATE OR REPLACE FUNCTION` | membuat atau mengganti function |
| `CREATE OR REPLACE PROCEDURE` | membuat atau mengganti procedure |
| `CALL` | menjalankan procedure |

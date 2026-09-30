# Latihan — Pertemuan 19

> Catatan: isi `customers.csv` di bawah adalah data contoh (7 baris: `id,name,city,status`). Sesuaikan output dengan hasil terminal asli jika berbeda.

## Soal 1: Navigasi ke `p19_data/raw` dengan relative path
```bash
cd p19_data/raw
pwd
```
**Output:**
```
/home/kevin/p19_data/raw
```
**Penjelasan:** Dari `/home/kevin`, path relatif `p19_data/raw` langsung menunjuk ke tujuan tanpa menulis `/home/kevin`. `pwd` memastikan posisinya benar.

---

## Soal 2: Buat directory `archive` di dalam `raw/`
```bash
mkdir archive
ls
```
**Output:**
```
archive
customers.csv
```
**Penjelasan:** Posisi sudah di `raw/`, jadi `mkdir archive` otomatis membuatnya di sini. `ls` untuk verifikasi.

---

## Soal 3: Copy `customers.csv` ke `p19_data/backup/`
```bash
cp customers.csv ../backup/
ls
ls ../backup
```
**Output:**
```
archive
customers.csv
customers.csv
```
**Penjelasan:** `cp` menyalin tanpa menghapus file asli, jadi `customers.csv` ada di `raw/` (output `ls` pertama) dan di `backup/` (output `ls ../backup`).

---

## Soal 4: Buat `customers_backup.csv` lalu pindahkan ke `backup/`
```bash
touch customers_backup.csv
mv customers_backup.csv ../backup/
ls
ls ../backup
```
**Output:**
```
archive
customers.csv
customers.csv
customers_backup.csv
```
**Penjelasan:** `mv` memindahkan file, sehingga `raw/` (dua baris pertama) tidak lagi memiliki `customers_backup.csv`, sedangkan `backup/` (dua baris terakhir) sekarang memilikinya.

---

## Soal 5: Rename `customers_backup.csv` menjadi `customers_2026_backup.csv`
```bash
cd ../backup
mv customers_backup.csv customers_2026_backup.csv
ls
```
**Output:**
```
customers.csv
customers_2026_backup.csv
```
**Penjelasan:** `mv` dengan sumber dan tujuan di directory yang sama berfungsi sebagai rename.

---

## Soal 6: Atur permission `config.txt` menjadi `rw-r--r--`
```bash
cd ../raw
touch config.txt
chmod 644 config.txt
ls -l config.txt
```
**Output:**
```
-rw-r--r-- 1 kevin kevin 0 Sep 30 04:11 config.txt
```
**Penjelasan:** `rw-` = 4+2 = 6, `r--` = 4, `r--` = 4, sehingga `chmod 644`.

---

## Soal 7: Tampilkan 3 baris pertama dan 2 baris terakhir `customers.csv`
```bash
head -n 3 customers.csv
tail -n 2 customers.csv
```
**Output:**
```
id,name,city,status
1,Andi,Jakarta,active
2,Budi,Bandung,inactive
6,Fani,Jakarta,active
7,Gilang,Medan,inactive
```
**Penjelasan:** `head -n` dan `tail -n` menampilkan sebagian file saja, tanpa membanjiri terminal seperti `cat`.

---

## Soal 8: Cari customer dari Jakarta dan berstatus inactive
```bash
grep "Jakarta" customers.csv
grep "inactive" customers.csv
```
**Output:**
```
1,Andi,Jakarta,active
3,Citra,Jakarta,inactive
6,Fani,Jakarta,active
2,Budi,Bandung,inactive
3,Citra,Jakarta,inactive
7,Gilang,Medan,inactive
```
**Penjelasan:** `grep` menampilkan hanya baris yang mengandung teks yang dicari. Tiga baris pertama hasil `Jakarta`, tiga baris terakhir hasil `inactive`.

---

## Soal 9: Skenario log `pipeline.log`
```bash
cd ../logs
cat > pipeline.log << 'EOF'
2026-09-27 INFO pipeline started
2026-09-27 INFO extracting customers
2026-09-27 ERROR database connection failed
2026-09-27 INFO retrying connection
2026-09-27 ERROR timeout
2026-09-27 INFO pipeline finished
EOF

head -n 2 pipeline.log
tail -n 2 pipeline.log
grep "ERROR" pipeline.log
```
**Output:**
```
2026-09-27 INFO pipeline started
2026-09-27 INFO extracting customers
2026-09-27 ERROR timeout
2026-09-27 INFO pipeline finished
2026-09-27 ERROR database connection failed
2026-09-27 ERROR timeout
```
**Penjelasan:** `head` untuk awal proses (2 baris pertama), `tail` untuk kejadian terbaru (2 baris berikutnya), `grep "ERROR"` untuk langsung menemukan baris masalah (2 baris terakhir).

---

## Soal 10: Mini Data Engineering Task
```bash
# A. Pastikan berada di p19_data/
cd ~/p19_data
pwd

# B. Buat processed/ kalau belum ada
mkdir -p processed

# C. Copy customers.csv ke processed/
cp raw/customers.csv processed/customers_processed.csv

# D. Pastikan file original masih ada
ls raw

# E. Cek hasil processed file
head processed/customers_processed.csv

# F. Cari customer dari Jakarta
grep "Jakarta" processed/customers_processed.csv

# G. Backup processed file
cp processed/customers_processed.csv backup/customers_processed_backup.csv

# H. Verifikasi struktur akhir
ls -R
```
**Output:**
```
/home/kevin/p19_data
archive
config.txt
customers.csv
id,name,city,status
1,Andi,Jakarta,active
2,Budi,Bandung,inactive
3,Citra,Jakarta,inactive
4,Dewi,Surabaya,active
5,Eko,Batam,active
6,Fani,Jakarta,active
7,Gilang,Medan,inactive
1,Andi,Jakarta,active
3,Citra,Jakarta,inactive
6,Fani,Jakarta,active
.:
backup
logs
processed
raw

./backup:
customers.csv
customers_2026_backup.csv
customers_processed_backup.csv

./logs:
pipeline.log

./processed:
customers_processed.csv

./raw:
archive
config.txt
customers.csv

./raw/archive:
```
**Penjelasan:** `mkdir -p` aman dijalankan walau directory sudah ada. `cp` (bukan `mv`) dipakai supaya data di `raw/` tetap utuh sebagai sumber asli.

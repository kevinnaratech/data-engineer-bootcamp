# Latihan — Meeting 19

## Soal 1: Navigasi ke `p19_data/raw` dengan relative path
```bash
cd p19_data/raw
pwd
```
**Output:**
```

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
[paste output asli dari terminal]
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
[paste output asli dari terminal]
```
**Penjelasan:** `cp` menyalin tanpa menghapus file asli, jadi `customers.csv` ada di `raw/` dan `backup/`.

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
[paste output asli dari terminal]
```
**Penjelasan:** `mv` memindahkan file, sehingga `raw/` tidak lagi memiliki `customers_backup.csv`.

---

## Soal 5: Rename `customers_backup.csv` menjadi `customers_2026_backup.csv`
```bash
cd ../backup
mv customers_backup.csv customers_2026_backup.csv
ls
```
**Output:**
```
[paste output asli dari terminal]
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
[paste output asli dari terminal]
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
[paste output asli dari terminal]
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
[paste output asli dari terminal]
```
**Penjelasan:** `grep` menampilkan hanya baris yang mengandung teks yang dicari.

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
[paste output asli dari terminal]
```
**Penjelasan:** `head` untuk awal proses, `tail` untuk kejadian terbaru, `grep "ERROR"` untuk langsung menemukan baris masalah.

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
[paste output asli dari terminal]
```
**Penjelasan:** `mkdir -p` aman dijalankan walau directory sudah ada. `cp` (bukan `mv`) dipakai supaya data di `raw/` tetap utuh sebagai sumber asli.
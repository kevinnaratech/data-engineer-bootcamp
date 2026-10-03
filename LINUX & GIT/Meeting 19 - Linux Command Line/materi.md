# Meeting 19 — Linux Command Line

## Ringkasan
Mempelajari navigasi struktur sistem file Linux dengan mengelola, menyalin, memindahkan, dan menghapus direktori atau file. Juga mempelajari cara membaca serta mencari teks di dalam file, sekaligus mengontrol keamanan sistem melalui pengaturan hak akses (permission) dan kepemilikan (ownership).

## Mental Model Filesystem

Filesystem Linux berbentuk pohon, dengan `/` sebagai root directory.

```text
/
├── home/
│   └── kevin/
│       ├── Documents/
│       ├── Downloads/
│       ├── kuliah/
│       └── backup/
├── etc/
├── var/
├── tmp/
└── ...
```

- `/` = root directory (paling atas)
- `/home/kevin` = home directory user `kevin`
- `~` = shortcut untuk `/home/kevin`, jadi `cd ~` sama dengan `cd /home/kevin`

Konteks Data Engineering:

```text
Linux server
    ↓
directory
    ↓
raw data
    ↓
CSV / JSON / log
    ↓
ETL pipeline
    ↓
database / data warehouse
```

## Konsep & Command

### [pwd]
Mengetahui posisi directory saat ini (print working directory).

```bash
pwd
```

Contoh output:

```text
/home/kevin
```

**Kenapa dipakai:** Command seperti `rm data.csv` akan mencari `data.csv` di directory tempat kita sekarang berada. Sebelum operasi yang memodifikasi file, biasakan `pwd` dan `ls` dulu.

### [ls]
Melihat isi directory.

```bash
ls        # isi directory
ls -l     # format detail (permission, owner, ukuran, tanggal)
ls -a     # termasuk hidden files (diawali titik)
ls -la    # detail + hidden files
```

Contoh hidden files: `.gitignore`, `.bashrc`

Contoh output `ls -l`:

```text
-rw-r--r-- 1 kevin kevin 1200 Sep 27 data.csv
```

### [cd]
Berpindah directory.

```bash
cd Documents               # masuk directory (relative path)
cd ..                      # naik satu level
cd ~                       # kembali ke home
cd -                       # kembali ke directory sebelumnya
cd /home/kevin/Documents   # absolute path
```

**Absolute vs relative path:**
- **Absolute** — dimulai dari `/`, menunjuk lokasi lengkap, tidak peduli posisi sekarang.
- **Relative** — dihitung dari posisi sekarang. Jika di `/home/kevin`, maka `cd Documents` = `/home/kevin/Documents`.

### [mkdir]
Membuat directory.

```bash
mkdir data_project
mkdir -p data_project/raw    # -p: buat nested directory sekaligus
```

**Kenapa dipakai:** Membuat struktur project, misalnya:

```text
etl_project/
├── raw/
├── processed/
├── scripts/
└── logs/
```

### [touch]
Membuat file kosong.

```bash
touch data.csv
touch raw_data.csv
```

### [cp]
Menyalin file atau directory. Format: `cp sumber tujuan`

```bash
cp data.csv backup_data.csv   # file original tetap ada
cp -r raw backup              # -r: recursive, salin seluruh isi directory
```

### [mv]
Memindahkan atau rename file/directory.

```bash
mv data.csv raw/               # pindah ke directory raw
mv data_lama.csv data_baru.csv # rename
```

**Catatan:** Tidak ada command khusus rename untuk penggunaan dasar; `mv` dipakai untuk keduanya.

### [rm]
Menghapus file atau directory.

```bash
rm data.csv        # hapus file
rmdir folder       # hapus directory kosong
rm -r folder       # hapus directory beserta isinya
rm -rf folder      # paksa hapus tanpa konfirmasi (HATI-HATI)
```

**Peringatan:** `rm` tidak punya recycle bin. File yang terhapus tidak bisa dikembalikan dengan mudah. Selalu cek `pwd` dan `ls` sebelum operasi destructive.

## Permission Linux

Jalankan `ls -l`:

```text
-rw-r--r-- 1 kevin kevin 1200 Sep 27 data.csv
```

Bagian permission (`-rw-r--r--`) dipecah menjadi:

```text
-    rw-    r--    r--
│    │      │      │
│    │      │      └── others
│    │      └───────── group
│    └──────────────── owner
└───────────────────── file type
```

### r, w, x

| Simbol | Untuk file | Untuk directory |
|--------|-----------|-----------------|
| `r` | boleh membaca | melihat isi directory |
| `w` | boleh mengubah | membuat/menghapus entry |
| `x` | boleh menjalankan | masuk/traverse directory |

**Catatan:** `x` pada directory bukan berarti "menjalankan folder", tapi izin untuk masuk ke dalamnya.

### Permission sebagai angka

```text
r = 4
w = 2
x = 1
```

| Simbol | Hitungan | Angka |
|--------|----------|-------|
| `rwx` | 4+2+1 | 7 |
| `rw-` | 4+2 | 6 |
| `r-x` | 4+1 | 5 |
| `r--` | 4 | 4 |

Contoh `rwxr-xr--`:

```text
owner  = rwx = 7
group  = r-x = 5
others = r-- = 4
→ chmod 754 file
```

### [chmod]
Mengubah permission (change mode).

```bash
chmod 644 data.csv    # owner: rw, group: r, others: r
chmod 755 script.sh   # owner: rwx, group: r-x, others: r-x
```

**Kenapa dipakai:** `644` umum untuk file data, `755` umum untuk script yang perlu dieksekusi.

### [chown]
Mengubah kepemilikan file (change owner). Biasanya butuh `sudo`.

```bash
sudo chown kevin data.csv          # ganti owner
sudo chown kevin:kevin data.csv    # ganti owner + group
```

**Peringatan:** Jangan asal memakai `chown -R` pada directory sistem. Untuk latihan, gunakan file milik sendiri.

## Membaca & Mencari Isi File

### [cat]
Menampilkan seluruh isi file.

```bash
cat data.csv
```

Contoh output:

```text
id,name,score
1,Andi,80
2,Budi,90
3,Citra,85
```

**Catatan:** Cocok untuk file kecil. Jangan `cat` file log berukuran besar (misalnya 10 GB) karena akan membanjiri terminal.

### [head]
Menampilkan bagian awal file (default 10 baris).

```bash
head data.csv
head -n 5 data.csv    # 5 baris pertama
```

**Kenapa dipakai:** Cek struktur dataset dengan cepat, misalnya `head -n 5 customers.csv`.

### [tail]
Menampilkan bagian akhir file (default 10 baris).

```bash
tail data.csv
tail -n 5 data.csv          # 5 baris terakhir
tail -n 20 pipeline.log     # 20 baris log terbaru
```

**Kenapa dipakai:** Melihat event terbaru di log tanpa membaca seluruh file.

### [grep]
Mencari baris yang mengandung teks/pattern tertentu.

```bash
grep "ERROR" pipeline.log       # baris yang mengandung ERROR
grep "Jakarta" customers.csv    # baris yang mengandung Jakarta
grep -i "error" pipeline.log    # -i: case-insensitive
```

Contoh output:

```text
2026-09-27 ERROR database connection failed
2026-09-27 ERROR timeout
```

## Skenario Data Engineering

Struktur project:

```text
etl_project/
├── raw/
│   └── customers.csv
├── processed/
├── logs/
│   └── pipeline.log
└── scripts/
```

Workflow sederhana:

```bash
pwd                                  # 1. cek posisi
ls                                   # 2. cek isi directory
head -n 5 raw/customers.csv          # 3. cek struktur data
grep "ERROR" logs/pipeline.log       # 4. cari error
tail -n 20 logs/pipeline.log         # 5. cek log terbaru
```

Pola ini akan tetap dipakai saat bekerja dengan ETL, Airflow, Docker, Linux server, cloud VM, dan pipeline logs.

## Cheat Sheet

| Command | Fungsi |
|---------|--------|
| `pwd` | tampilkan posisi sekarang |
| `ls -la` | isi directory detail + hidden |
| `cd` | pindah directory |
| `mkdir -p` | buat directory (termasuk nested) |
| `touch` | buat file kosong |
| `cp` / `cp -r` | salin file / directory |
| `mv` | pindah / rename |
| `rm` / `rm -r` | hapus file / directory |
| `chmod` | ubah permission |
| `chown` | ubah owner |
| `cat` | tampilkan seluruh isi file |
| `head` / `tail` | awal / akhir file |
| `grep` | cari teks |

        
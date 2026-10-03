      # Meeting 20 — Piping, Redirection, Cron & Git

## Ringkasan
Mempelajari cara menggabungkan command Linux dengan piping (`|`), menyimpan output ke file dengan redirection (`>` dan `>>`), serta konsep dasar penjadwalan otomatis dengan cron job. Juga mempelajari dasar Git dari command line: cek dan setup Git, membuat repository (`git init`), menyimpan perubahan (`git add`, `git commit`), serta sinkronisasi dengan remote (`git push`, `git pull`, `git clone`).

## Konsep & Command

### [Piping `|`]
Mengirim output command sebelumnya menjadi input command berikutnya.

```bash
command1 | command2
```

Analogi pipeline ETL:

```text
Data Source → Transform → Filter → Output
command A   → command B → command C
```

Contoh, jika folder berisi `data.csv`, `users.csv`, `notes.txt`, `script.py`:

```bash
ls | grep csv
```

Alur:

```text
ls
 ↓
daftar file
 ↓
grep csv
 ↓
hanya file yang mengandung "csv"
```

Output:

```text
data.csv
users.csv
```

**Catatan:** `|` bukan menyimpan output ke file. Dia hanya meneruskan output command sebelumnya sebagai input command berikutnya.

### [Kombinasi piping]
Pipe bisa dirangkai lebih dari dua command.

```bash
ls | grep csv | head -n 2
```

Alur:

```text
ls → grep csv → head -n 2 → 2 file pertama
```

**Kenapa dipakai:** Mirip konsep data processing: extract → filter → limit. Inilah kenapa command line Linux terasa powerful untuk pekerjaan data.

### [Redirection `>`]
Menulis output ke file dengan **overwrite**.

```bash
ls > files.txt
```

- Jika `files.txt` belum ada, file dibuat.
- Jika sudah ada, isinya ditimpa.

Contoh:

```bash
echo "hello" > test.txt 
cat test.txt
```

Output:

```text
hello
```

Lalu:

```bash
echo "world" > test.txt
cat test.txt
```

Output:

```text
world
```

`hello` hilang karena `>` melakukan overwrite.

### [Redirection `>>`]
Menulis output ke file dengan **append** (ditambahkan di akhir).

```bash
echo "hello" > log.txt
echo "world" >> log.txt
cat log.txt
```

Output:

```text
hello
world
```

**Kenapa dipakai:** Berguna untuk logging, karena file log terus bertambah.

```bash
echo "ETL started" >> etl.log
echo "ETL finished" >> etl.log
```

### [Perbedaan `|`, `>`, dan `>>`]

| Operator | Fungsi | Contoh |
|----------|--------|--------|
| `\|` | output → input command berikutnya | `ls \| grep csv` |
| `>` | output → file, overwrite | `ls > files.txt` |
| `>>` | output → file, append | `ls >> files.txt` |

Ringkasnya:

```text
|   → command ke command
>   → command ke file (timpa)
>>  → command ke file (tambah di akhir)
```

### [Cron Job]
Cron adalah mekanisme Linux untuk menjalankan command secara otomatis berdasarkan jadwal.

```bash
crontab -l    # lihat daftar cron milik user
crontab -e    # edit cron
```

Format dasar:

```text
minute hour day month weekday command
```

Contoh: jalankan `etl.py` setiap hari pukul 02:00.

```bash
0 2 * * * python3 /home/user/etl.py
```

Cara membaca:

| Field | Nilai | Arti |
|-------|-------|------|
| minute | `0` | menit ke-0 |
| hour | `2` | jam 2 |
| day | `*` | setiap hari |
| month | `*` | setiap bulan |
| weekday | `*` | setiap hari dalam minggu |

**Kenapa dipakai:** Yang penting dipahami adalah konsepnya, bukan menghafal syntax:

```text
cron
 ↓
scheduler
 ↓
command/script
 ↓
jalan otomatis
```

Nanti di Airflow, konsep scheduling ini jauh lebih powerful.

## Git

### Model kerja Git

```text
Working Directory
       ↓
    git add
       ↓
     Staging
       ↓
   git commit
       ↓
 Local Repository
       ↓
    git push
       ↓
 GitHub / Remote
```

Pahami modelnya, jangan hanya menghafal command.

### [git --version]
Mengecek apakah Git sudah terinstall.

```bash
git --version
```

Contoh output:

```text
git version 2.x.x
```

Jika muncul versi, Git sudah terinstall.

### [git config]
Setup identity, supaya Git tahu siapa yang membuat commit.

```bash
git config --global user.name "Nama Lu"
git config --global user.email "email@example.com"
git config --global --list    # cek konfigurasi
```

### [git init]
Membuat repository Git di directory yang sudah ada.

Contoh struktur project:

```text
data-engineering/
├── pertemuan-19/
├── pertemuan-20/
└── README.md
```

```bash
cd data-engineering
git init
```

Git membuat directory tersembunyi `.git/` yang menyimpan seluruh informasi repository.

**Peringatan:** Jangan sembarangan menghapus `.git`.

### [git status]
Melihat kondisi repository saat ini. Command ini akan sering dipakai.

```bash
git status
```

Contoh: setelah `touch data.csv`, `git status` akan memberi tahu bahwa `data.csv` belum ditrack (untracked).

### [git add]
Memasukkan perubahan ke staging area.

```bash
git add data.csv    # satu file
git add .           # semua perubahan di directory tersebut
```

```text
data.csv → git add → STAGING AREA
```

**Catatan:** Jangan biasakan langsung `git add .` tanpa melihat `git status` dulu.

### [git commit]
Menyimpan snapshot dari perubahan yang sudah di-stage ke history Git.

```bash
git commit -m "Add raw data file"
```

Commit adalah checkpoint/version snapshot:

```text
Commit A → Commit B → Commit C
```

### [git push]
Mengirim commit dari repository lokal ke remote (GitHub).

```bash
git push
```

```text
LOCAL REPOSITORY → push → REMOTE / GITHUB
```

### [git pull]
Mengambil perubahan dari remote dan menggabungkannya ke repository lokal.

```bash
git pull
```

```text
GITHUB → pull → LOCAL
```

### [git clone]
Mengambil copy repository yang sudah ada di GitHub.

```bash
git clone https://github.com/user/data-engineering.git
```

**Kenapa dipakai:** Jangan `git init` lalu copy file manual. `git clone` juga mengambil seluruh history repository, bukan hanya file terakhir.

## Workflow Git Dasar

```text
edit file
   ↓
git status
   ↓
git add
   ↓
git commit
   ↓
git push
```

Contoh:

```bash
git status
git add .
git commit -m "Complete Pertemuan 20"
git push
```

**Kebiasaan baik:** Selalu jalankan `git status` dulu sebelum `git add`.

## Cheat Sheet

| Command | Fungsi |
|---------|--------|
| `cmd1 \| cmd2` | output cmd1 jadi input cmd2 |
| `cmd > file` | output ke file (overwrite) |
| `cmd >> file` | output ke file (append) |
| `crontab -l` | lihat cron job |
| `crontab -e` | edit cron job |
| `git --version` | cek Git terinstall |
| `git config --global` | setup name/email |
| `git init` | buat repository baru |
| `git status` | cek kondisi repository |
| `git add` | stage perubahan |
| `git commit -m` | simpan snapshot |
| `git push` | kirim ke remote |
| `git pull` | ambil dari remote |
| `git clone` | copy repository dari remote |
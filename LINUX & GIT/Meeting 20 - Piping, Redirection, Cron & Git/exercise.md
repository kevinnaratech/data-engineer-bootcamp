# Latihan — Pertemuan 20

> Catatan: output Soal 1–10 berasal dari simulasi command asli dengan folder contoh berisi `data.csv`, `sales.csv`, `users.csv`, `notes.txt`, `script.py`, dan `pipeline.log`. Output Soal 11–15 (GitHub dan cron) adalah bentuk output yang umum muncul, jadi sesuaikan dengan hasil terminal asli lu (URL, jumlah objects, jam, dll).

# A. Piping & Redirection

## Soal 1: Filter file `.csv` dengan piping
```bash
ls | grep csv
```
**Output:**
```
data.csv
sales.csv
users.csv
```
**Penjelasan:** `ls` menghasilkan daftar file, lalu `grep csv` hanya meneruskan nama yang mengandung `csv`.

---

## Soal 2: Tampilkan file `.csv` lalu ambil 2 hasil pertama
```bash
ls | grep csv | head -n 2
```
**Output:**
```
data.csv
sales.csv
```
**Penjelasan:** Rangkaian extract → filter → limit: `ls`, `grep csv`, lalu `head -n 2`.

---

## Soal 3: Simpan daftar file `.csv` ke `csv_files.txt`
```bash
ls | grep csv > csv_files.txt
cat csv_files.txt
```
**Output:**
```
data.csv
sales.csv
users.csv
```
**Penjelasan:** `>` menulis hasil pipe ke file (overwrite). `cat` untuk verifikasi isi file.

---

## Soal 4: Append pesan ke `pipeline.log` tanpa menghapus isi lama
```bash
echo "ETL pipeline started" >> pipeline.log
echo "ETL pipeline finished" >> pipeline.log
cat pipeline.log
```
**Output:**
```
2026-09-27 INFO pipeline started
2026-09-27 INFO pipeline finished
ETL pipeline started
ETL pipeline finished
```
**Penjelasan:** `>>` menambahkan di akhir file, sedangkan `>` akan menimpa isi lama. Dua baris pertama adalah isi lama yang tetap ada.

---

## Soal 5: Piping + redirection ke `data_sources.txt`
```bash
ls | grep csv > data_sources.txt
cat data_sources.txt
```
**Output:**
```
csv_files.txt
data.csv
sales.csv
users.csv
```
**Penjelasan:** Karena `csv_files.txt` dibuat di Soal 3, namanya ikut tersaring karena mengandung `csv`.

---

# B. Git Basic

## Soal 6: Cek versi Git
```bash
git --version
```
**Output:**
```
git version 2.43.0
```
**Penjelasan:** Jika versi muncul, Git sudah terinstall.

---

## Soal 7: Initialize repository
```bash
git init
```
**Output:**
```
Initialized empty Git repository in /home/kevin/p19_data/.git/
```
**Penjelasan:** Membuat directory tersembunyi `.git/` yang menyimpan seluruh data repository.

---

## Soal 8: Cek status setelah `git init`
```bash
git status
```
**Output:**
```
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	csv_files.txt
	data.csv
	data_sources.txt
	notes.txt
	pipeline.log
	sales.csv
	script.py
	users.csv

nothing added to commit but untracked files present (use "git add" to track)
```
**Penjelasan:** Semua file masih untracked karena belum ada yang di-`git add`. Folder yang berisi file (misalnya `raw/`, `logs/`) juga akan muncul sebagai untracked.

---

## Soal 9: Selective staging `README.md` dan `pipeline.py`
```bash
touch README.md pipeline.py
git add README.md pipeline.py
git status
```
**Output:**
```
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   README.md
	new file:   pipeline.py

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	csv_files.txt
	data.csv
	data_sources.txt
	notes.txt
	pipeline.log
	sales.csv
	script.py
	users.csv

```
**Penjelasan:** Hanya dua file yang masuk "Changes to be committed". File lain tetap untracked karena tidak ikut di-add (bukan `git add .`).

---

## Soal 10: Commit dan verifikasi
```bash
git commit -m "Add initial pipeline setup"
git status
git log --oneline
```
**Output:**
```
[master (root-commit) 2677776] Add initial pipeline setup
 2 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 README.md
 create mode 100644 pipeline.py
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	csv_files.txt
	data.csv
	data_sources.txt
	notes.txt
	pipeline.log
	sales.csv
	script.py
	users.csv

nothing added to commit but untracked files present (use "git add" to track)
2677776 Add initial pipeline setup
```
**Penjelasan:** Hash commit (`2677776`) akan berbeda di komputer lu. `git status` menunjukkan `README.md` dan `pipeline.py` sudah ter-commit, sisanya masih untracked.

---

# C. GitHub — Remote Repository

## Soal 11: Hubungkan local repo ke GitHub
```bash
git remote add origin https://github.com/kevinnaratech/p19_data.git
git remote -v
```
**Output:**
```
origin	https://github.com/kevinnaratech/p19_data.git (fetch)
origin	https://github.com/kevinnaratech/p19_data.git (push)
```
**Penjelasan:** `origin` adalah nama (alias) untuk remote repository. `git remote -v` menampilkan URL untuk fetch dan push.

---

## Soal 12: Push `master` ke GitHub
```bash
git push -u origin master
```
**Output:**
```
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Writing objects: 100% (3/3), 250 bytes | 250.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/kevinnaratech/p19_data.git
 * [new branch]      master -> master
branch 'master' set up to track 'origin/master'.
```
**Penjelasan:** `-u` menjadikan `origin/master` sebagai upstream, sehingga selanjutnya cukup `git push` dan `git pull`.

---

## Soal 13: Pull dari remote
```bash
git pull
```
**Output:**
```
Already up to date.
```
**Penjelasan:** Tidak ada perubahan baru di remote. Jika ada, Git akan mengunduh dan menggabungkannya ke repository lokal.

---

## Soal 14: Clone repository dari GitHub
```bash
git clone https://github.com/kevinnaratech/p19_data.git
ls p19_data
```
**Output:**
```
Cloning into 'p19_data'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
README.md
pipeline.py
```
**Penjelasan:** `git clone` membuat copy repository beserta history-nya. Hanya file yang sudah di-commit (`README.md` dan `pipeline.py`) yang ikut ke hasil clone. Jalankan di folder lain, bukan di dalam repo yang sama.

---

# D. Cron Job

## Soal 15: Cron sederhana setiap 1 menit
```bash
touch ~/p19_data/cron.log
crontab -e
```
Tambahkan baris berikut di crontab:
```
* * * * * echo "ETL pipeline running" >> /home/kevin/p19_data/cron.log
```
Setelah menunggu 1–2 menit:
```bash
crontab -l
cat ~/p19_data/cron.log
```
**Output:**
```
* * * * * echo "ETL pipeline running" >> /home/kevin/p19_data/cron.log
ETL pipeline running
ETL pipeline running
```
**Penjelasan:** Lima tanda `*` berarti dijalankan setiap menit. `>>` dipakai supaya log bertambah tiap eksekusi, bukan tertimpa. Jumlah baris di `cron.log` bertambah satu per menit.
# Exercise — Pertemuan 21

> Catatan: output berasal dari simulasi command asli (Git 2.43) pada repository `p19_data` yang sudah punya `README.md` dan `pipeline.py` dari commit sebelumnya. Hash commit dan jumlah commit "ahead of origin" akan berbeda di komputer lu, sesuaikan dengan output asli. Folder `raw/`, `processed/`, `logs/`, `backup/` dan file `cron.log` diasumsikan ada.

## Exercise 1: Branching
```bash
git branch
git switch -c feature/etl-validation
# buat validation.md (isi minimal 3 validasi ETL)
git add validation.md
git commit -m "Add ETL validation notes"
git switch master
ls
```
Isi `validation.md`:
```markdown
# ETL Data Validation

- Check null values
- Check duplicate records
- Check invalid data types
```
**Output:**
```
* master
Switched to a new branch 'feature/etl-validation'
[feature/etl-validation cf6cb03] Add ETL validation notes
 1 file changed, 5 insertions(+)
 create mode 100644 validation.md
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
README.md
backup
cron.log
logs
pipeline.py
processed
raw
```
**Penjelasan:** Setelah pindah ke `master`, `validation.md` tidak ada di `ls`, karena file itu hanya ada di branch `feature/etl-validation` sampai di-merge.

---

## Exercise 2: Merge
```bash
git switch master
git merge feature/etl-validation
git log --oneline --graph --all
```
**Output:**
```
Updating 0da0aeb..cf6cb03
Fast-forward
 validation.md | 5 +++++
 1 file changed, 5 insertions(+)
 create mode 100644 validation.md
* cf6cb03 Add ETL validation notes
* 0da0aeb Add initial pipeline setup
```
**Penjelasan:** `validation.md` muncul di `master` karena merge membawa commit dari branch fitur ke `master`. Karena `master` tidak punya commit baru sejak branch dibuat, hasilnya `Fast-forward` dan graph-nya lurus tanpa merge commit.

---

## Exercise 3: .gitignore
```bash
git status --short
touch .gitignore
# isi .gitignore:
#   logs/
#   cron.log
#   backup/
#   raw/
#   processed/
git status
git add .gitignore
git commit -m "Add .gitignore"
git status
```
**Output:**
```
?? backup/
?? cron.log
?? logs/
?? processed/
?? raw/
```
Setelah `.gitignore` dibuat dan diisi, `git status`:
```
On branch master
Your branch is ahead of 'origin/master' by 1 commit.
  (use "git push" to publish your local commits)

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitignore

nothing added to commit but untracked files present (use "git add" to track)
```
Setelah `.gitignore` di-commit:
```
On branch master
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```
**Penjelasan:** Artifact (`raw/`, `processed/`, `logs/`, `backup/`, `cron.log`) tidak lagi muncul sebagai untracked. Yang tersisa hanya `.gitignore` itu sendiri, yang perlu di-commit supaya working tree bersih (dibutuhkan untuk target di Exercise 6).

---

## Exercise 4: Simulasi Conflict

### Langkah A — Branch pertama
```bash
git switch -c feature/pipeline-config
# edit pipeline.py:
#   PIPELINE_NAME = "sales_etl"
#   SOURCE = "raw/sales.csv"
#   TARGET = "processed/sales.csv"
#
#   print(f"Running {PIPELINE_NAME}")
git add pipeline.py
git commit -m "Configure sales ETL pipeline"
```
**Output:**
```
Switched to a new branch 'feature/pipeline-config'
[feature/pipeline-config c2dbed8] Configure sales ETL pipeline
 1 file changed, 5 insertions(+)
```

### Langkah B — Branch kedua
```bash
git switch master
git switch -c feature/pipeline-monitoring
# edit pipeline.py:
#   PIPELINE_NAME = "customer_etl"
#   SOURCE = "raw/customers.csv"
#   TARGET = "processed/customers.csv"
#
#   print(f"Running {PIPELINE_NAME}")
git add pipeline.py
git commit -m "Configure customer ETL pipeline"
```
**Output:**
```
Switched to branch 'master'
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)
Switched to a new branch 'feature/pipeline-monitoring'
[feature/pipeline-monitoring f4190b5] Configure customer ETL pipeline
 1 file changed, 5 insertions(+)
```

### Langkah C — Buat Conflict
```bash
git switch master
git merge feature/pipeline-config
git merge feature/pipeline-monitoring
git status
cat pipeline.py
```
**Output:**
```
Switched to branch 'master'
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)
Updating 9e5c591..c2dbed8
Fast-forward
 pipeline.py | 5 +++++
 1 file changed, 5 insertions(+)
Auto-merging pipeline.py
CONFLICT (content): Merge conflict in pipeline.py
Automatic merge failed; fix conflicts and then commit the result.
On branch master
Your branch is ahead of 'origin/master' by 3 commits.
  (use "git push" to publish your local commits)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
	both modified:   pipeline.py

no changes added to commit (use "git add" and/or "git commit -a")
<<<<<<< HEAD
PIPELINE_NAME = "sales_etl"
SOURCE = "raw/sales.csv"
TARGET = "processed/sales.csv"
=======
PIPELINE_NAME = "customer_etl"
SOURCE = "raw/customers.csv"
TARGET = "processed/customers.csv"
>>>>>>> feature/pipeline-monitoring

print(f"Running {PIPELINE_NAME}")
```
**Penjelasan:** Merge pertama berhasil (fast-forward). Merge kedua conflict karena kedua branch mengubah baris yang sama di `pipeline.py`.

---

## Exercise 5: Resolve Conflict
```bash
# edit pipeline.py, pilih versi sales dan hapus semua marker:
#   PIPELINE_NAME = "sales_etl"
#   SOURCE = "raw/sales.csv"
#   TARGET = "processed/sales.csv"
#
#   print(f"Running {PIPELINE_NAME}")
git add pipeline.py
git status
git commit -m "Merge pipeline monitoring and resolve conflict"
```
**Output:**
```
On branch master
Your branch is ahead of 'origin/master' by 3 commits.
  (use "git push" to publish your local commits)

All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

[master e8eef23] Merge pipeline monitoring and resolve conflict
```
**Penjelasan:** `git add` menandai conflict sudah resolved ("All conflicts fixed"), lalu `git commit` menyelesaikan merge.

---

## Exercise 6: Verify
```bash
git log --oneline --graph --all
python3 pipeline.py
git status
```
**Output:**
```
*   e8eef23 Merge pipeline monitoring and resolve conflict
|\  
| * f4190b5 Configure customer ETL pipeline
* | c2dbed8 Configure sales ETL pipeline
|/  
* 9e5c591 Add .gitignore
* cf6cb03 Add ETL validation notes
* 0da0aeb Add initial pipeline setup
Running sales_etl
On branch master
Your branch is ahead of 'origin/master' by 5 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
```
**Penjelasan:** Graph menunjukkan dua branch bercabang lalu bertemu di merge commit. Script mengeluarkan `Running sales_etl` sesuai versi yang dipilih, dan working tree bersih.

---

## Exercise 7: Cleanup
```bash
git branch -d feature/etl-validation
git branch -d feature/pipeline-config
git branch -d feature/pipeline-monitoring
git branch
```
**Output:**
```
Deleted branch feature/etl-validation (was cf6cb03).
Deleted branch feature/pipeline-config (was c2dbed8).
Deleted branch feature/pipeline-monitoring (was f4190b5).
* master
```
**Penjelasan:** `-d` hanya menghapus branch yang sudah di-merge, jadi lebih aman dibanding `-D`.

---

## Exercise 8: Push ke GitHub
```bash
git status
git push origin master
git status
```
**Output:**
```
On branch master
Your branch is ahead of 'origin/master' by 5 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
Enumerating objects: 22, done.
Counting objects: 100% (22/22), done.
Delta compression using up to 8 threads
Compressing objects: 100% (14/14), done.
Writing objects: 100% (21/21), 2.10 KiB | 2.10 MiB/s, done.
Total 21 (delta 4), reused 0 (delta 0), pack-reused 0
To https://github.com/kevinnaratech/p19_data.git
   0da0aeb..e8eef23  master -> master
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```
**Penjelasan:** Bagian `Enumerating ... Writing objects` adalah bentuk umum output push ke GitHub (angka bisa berbeda di terminal lu). Setelah push, `master` sama dengan `origin/master`.

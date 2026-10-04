# Meeting 21 — Git Lanjutan + Review Bulan 1

## Ringkasan
Mempelajari Git lanjutan: membuat branch untuk pengembangan fitur terpisah, menggabungkan perubahan dengan merge, memahami dan menyelesaikan merge conflict, melihat history dengan visual graph, mengabaikan file generated dengan `.gitignore`, serta membersihkan branch yang sudah selesai. Seluruhnya mendekati workflow Git di project nyata.

## Konsep & Command

### [Git Branch]
Branch adalah jalur pengembangan terpisah dalam Git. Tujuannya supaya kita bisa mengerjakan fitur atau perubahan tanpa langsung mengganggu branch utama.

```text
master
   │
   └── feature/etl-validation
```

Konvensi umum:

| Branch | Fungsi |
|--------|--------|
| `master` / `main` | versi utama/stabil |
| `feature/...` | pengembangan fitur |
| `bugfix/...` | perbaikan bug |

```bash
git branch                          # lihat daftar branch
git switch -c feature/nama-fitur    # buat branch sekaligus pindah
git switch master                   # pindah branch
```

Contoh:

```bash
git switch -c feature/etl-validation
```

### [Git Merge]
Menggabungkan perubahan dari satu branch ke branch lain.

```text
feature/etl-validation
            │
            ↓
          merge
            │
            ↓
          master
```

Workflow: pindah ke branch **tujuan**, lalu merge branch sumber.

```bash
git switch master
git merge feature/etl-validation
```

Artinya: ambil perubahan dari `feature/etl-validation` dan gabungkan ke `master`.

**Catatan penting:** Merge dilakukan dari branch tujuan, bukan branch sumber.

**Fast-forward:** Jika `master` tidak punya commit baru sejak branch dibuat, Git cukup menggeser pointer `master` maju (output `Fast-forward`) tanpa membuat merge commit. Merge commit baru muncul ketika kedua branch sama-sama punya commit baru.

### [Merge Conflict]
Conflict terjadi ketika Git tidak bisa menentukan perubahan mana yang harus dipakai, misalnya dua branch mengubah baris yang sama.

```text
Branch A:  PIPELINE_NAME = "sales_etl"
Branch B:  PIPELINE_NAME = "customer_etl"
```

Saat di-merge, Git membuat marker di dalam file:

```text
<<<<<<< HEAD
PIPELINE_NAME = "sales_etl"
=======
PIPELINE_NAME = "customer_etl"
>>>>>>> feature/pipeline-monitoring
```

Arti marker:

| Marker | Arti |
|--------|------|
| `<<<<<<< HEAD` | perubahan dari branch yang sedang aktif |
| `=======` | pemisah antara dua versi |
| `>>>>>>> nama-branch` | perubahan dari branch yang sedang di-merge |

### [Resolve Conflict]
Langkah-langkah:

```bash
git status                  # cari file yang conflict (both modified)
nano pipeline.py            # edit file, pilih versi yang benar
git add pipeline.py         # tandai sudah resolved
git status                  # cek: "All conflicts fixed"
git commit -m "Merge pipeline monitoring and resolve conflict"
```

Pastikan semua marker `<<<<<<<`, `=======`, `>>>>>>>` sudah dihapus sebelum `git add`.

Contoh hasil akhir jika memilih versi sales:

```python
PIPELINE_NAME = "sales_etl"
SOURCE = "raw/sales.csv"
TARGET = "processed/sales.csv"

print(f"Running {PIPELINE_NAME}")
```

Jika ingin batal di tengah merge:

```bash
git merge --abort
```

### [Git History]
Melihat history commit.

```bash
git log --oneline                  # ringkas
git log --oneline --graph --all    # dengan visual percabangan semua branch
```

Contoh tampilan graph:

```text
*   merge commit
|\
| * feature B
* | feature A
|/
* initial commit
```

**Kenapa dipakai:** `--graph` berguna untuk melihat percabangan dan titik merge.

### [.gitignore]
Menentukan file/folder yang tidak ingin dilacak oleh Git.

Contoh untuk project Data Engineering:

```text
logs/
cron.log
backup/
raw/
processed/
```

**Kenapa dipakai:** Folder tersebut bisa berisi raw data, hasil processing, log, backup, file generated, atau credential/config tertentu. Semua itu tidak seharusnya masuk repository.

**Catatan:** `.gitignore` bukan mekanisme keamanan. Jika secret sudah pernah ter-commit, menambahkannya ke `.gitignore` tidak otomatis menghapus secret dari history. Selain itu, `.gitignore` hanya berlaku untuk file yang belum ditrack.

### [Delete Branch]
Hapus branch yang sudah selesai dan sudah di-merge.

```bash
git branch -d feature/etl-validation
git branch    # verifikasi
```

**Catatan:** `-d` hanya mau menghapus branch yang sudah di-merge. Idealnya branch yang selesai tidak dibiarkan menumpuk tanpa alasan.

## Workflow P21

```text
master
   │
   ├── feature/pipeline-config
   │        └── commit
   │
   └── feature/pipeline-monitoring
            └── commit

        ↓
      merge
        ↓
     CONFLICT
        ↓
    edit file
        ↓
     git add
        ↓
    git commit
        ↓
      master
```

Ini jauh lebih dekat dengan workflow Git di project nyata dibanding sekadar `git add`, `git commit`, `git push`.

## Cheat Sheet

| Command | Fungsi |
|---------|--------|
| `git branch` | lihat branch |
| `git switch -c <nama>` | buat branch + pindah |
| `git switch <nama>` | pindah branch |
| `git merge <branch>` | gabungkan branch ke branch aktif |
| `git merge --abort` | batalkan merge yang conflict |
| `git log --oneline --graph --all` | history visual semua branch |
| `git branch -d <nama>` | hapus branch yang sudah di-merge |
| `.gitignore` | daftar file/folder yang diabaikan Git |

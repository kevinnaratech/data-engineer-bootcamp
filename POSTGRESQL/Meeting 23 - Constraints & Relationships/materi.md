# Meeting 23 — Constraints & Relationships

## Ringkasan
Mempelajari constraint di PostgreSQL (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `CHECK`) untuk menjaga data tetap valid, serta relasi antar tabel (one-to-many dan many-to-many) beserta penerapannya pada desain Personal Finance Tracker.

## 1. Konsep: Kenapa Constraint Dibutuhkan?

```text
users

id | name  | email
---+-------+----------------
1  | Agung | agung@gmail.com
2  | Budi  | agung@gmail.com
3  |       | budi@gmail.com
```

Secara teknis, database mungkin bisa menerima data seperti itu kalau kita tidak memberikan aturan.

Masalahnya:

- dua user bisa punya email yang sama
- nama user kosong
- `id` bisa duplicate kalau kita tidak mengaturnya
- tabel transaksi bisa menunjuk ke user yang tidak ada

## 2. Lima Constraint Utama

| Constraint | Tujuan |
|------------|--------|
| `PRIMARY KEY` | Identitas unik sebuah row |
| `FOREIGN KEY` | Menjaga hubungan antar tabel |
| `UNIQUE` | Mencegah nilai duplicate |
| `NOT NULL` | Memastikan nilai wajib ada |
| `CHECK` | Memastikan nilai memenuhi aturan |

## 3. PRIMARY KEY

Identifier unik untuk setiap row.

Primary key harus:

1. unik
2. tidak boleh `NULL`

## 4. UNIQUE

`UNIQUE` berbeda dengan primary key. Satu tabel bisa punya banyak `UNIQUE`, sedangkan hanya boleh punya satu primary key.

Contoh:

```text
users
├── user_id  → PRIMARY KEY
├── email    → UNIQUE
└── username → UNIQUE
```

## 5. NOT NULL

Kolom ini wajib punya nilai.

## 6. CHECK

Digunakan ketika kita punya aturan bisnis sederhana yang harus dipenuhi oleh suatu row.

Contoh:

```text
amount > 0
age >= 18
salary > 0
```

`CHECK` digunakan untuk membatasi nilai berdasarkan expression yang harus bernilai true.

**Batasan:** Jangan menggunakan `CHECK` untuk memvalidasi hubungan antar tabel.

Misalnya, "`transaction.user_id` harus ada di tabel `users`" itu bukan tugas `CHECK`, tetapi tugas `FOREIGN KEY`.

## 7. Relationship

Misalnya ada tabel `users`, `accounts`, dan `transactions`. Satu user bisa punya banyak account?

```text
1 USER
   │
   ├── ACCOUNT
   ├── ACCOUNT
   └── ACCOUNT
```

Ini disebut **One-to-Many**: satu user → banyak account.

## 8. FOREIGN KEY

Bagaimana `accounts` mengetahui account itu milik user mana?

Kita simpan:

```text
accounts

account_id | user_id | name
-----------+---------+--------
1          | 101     | BCA
2          | 101     | Mandiri
3          | 102     | BCA
```

`user_id` di `accounts` adalah **FOREIGN KEY** yang menunjuk ke `users.user_id`.

Secara konsep:

```text
users
----------------
user_id  PK
name

       │ 1
       │
       │ N
       ▼

accounts
----------------
account_id  PK
user_id     FK
name
```

Foreign key menjaga **referential integrity**: nilai pada child table harus merujuk ke row yang valid pada parent table.

Misalnya `users` berisi:

```text
users

user_id
-------
101
102
```

Maka ini valid:

```text
accounts

account_id | user_id
-----------+--------
1          | 101
2          | 102
```

Tapi ini:

```text
account_id | user_id
-----------+--------
3          | 999
```

akan ditolak kalau `999` tidak ada di `users`.

Karena "User 999 siapa?" Database bilang, "Gua gak kenal."

## 9. Kenapa Ini Penting untuk Data Engineer?

Ini bukan cuma teori database. Bayangkan lu punya pipeline:

```text
Application
     │
     ▼
PostgreSQL
     │
     ▼
ETL
     │
     ▼
Data Warehouse
     │
     ▼
Analytics
```

Kalau database source punya data `transaction.user_id = 999` padahal user 999 tidak ada, pipeline lu bisa menghasilkan **orphan records**, yaitu data yang tidak punya parent.

Akibatnya:

```sql
JOIN users
ON users.user_id = transactions.user_id
```

bisa kehilangan transaksi tersebut.

Jadi constraint membantu menjaga data quality dari source sejak awal.

## 10. One-to-Many vs Many-to-Many

### One-to-Many

Contoh: User → Accounts. Satu user punya banyak account, tapi satu account hanya punya satu owner.

```text
users
  1
  │
  N
accounts
```

### Many-to-Many

Misalnya ada `students` dan `courses`. Satu student bisa mengambil banyak course, dan satu course juga punya banyak student.

```text
students
   N
   │
   N
courses
```

Masalahnya, kita tidak bisa sekadar menaruh satu `course_id` di student.

```text
student_id | course_id
-----------+----------
1          | 101
```

Padahal student bisa punya `101`, `102`, `103`, `104`. Maka kita butuh **junction table / bridge table**.

```text
students
    │
    │ 1
    ▼
student_courses
    ▲
    │ N
courses
```

Contohnya:

```text
student_courses

student_id | course_id
-----------+----------
1          | 101
1          | 102
1          | 103
2          | 101
2          | 104
```

Di sinilah **composite key** sering digunakan:

```sql
PRIMARY KEY (student_id, course_id)
```

Artinya kombinasi tersebut harus unik.

## 11. Studi Kasus: Personal Finance Tracker

Untuk tahap awal: `users`, `accounts`, `transactions`.

Relasinya:

```text
users
  │
  │ 1
  │
  │ N
accounts
  │
  │ 1
  │
  │ N
transactions
```

Artinya:

```text
1 user
  └── many accounts

1 account
  └── many transactions
```

Contoh data:

```text
users

id | name
---+------
1  | Agung
2  | Budi
```

```text
accounts

id | user_id | name
---+---------+--------
1  | 1       | BCA
2  | 1       | Cash
3  | 2       | Mandiri
```

```text
transactions

id | account_id | amount
---+------------+-------
1  | 1          | 500000
2  | 1          | 100000
3  | 2          | 50000
4  | 3          | 250000
```

Relationship:

```text
users
  │
  └── accounts
          │
          └── transactions
```

Ini sudah mulai terlihat seperti database production sederhana.

## 12. SQL Standard vs PostgreSQL

Konsep berikut adalah konsep relational database/SQL yang transferable:

- `PRIMARY KEY`
- `FOREIGN KEY`
- `UNIQUE`
- `CHECK`
- `NOT NULL`
- one-to-many
- many-to-many

Jadi kalau nanti pindah ke MySQL, SQL Server, atau Oracle, konsep dasarnya tetap kepakai.

Yang berbeda biasanya:

- syntax tertentu
- behavior tertentu
- fitur tambahan
- implementation detail

Ini skill yang jauh lebih penting daripada sekadar hafal syntax PostgreSQL.

## Cheat Sheet

| Konsep | Ringkasan |
|--------|-----------|
| `PRIMARY KEY` | unik + tidak boleh `NULL`, hanya satu per tabel |
| `UNIQUE` | tidak boleh duplicate, boleh banyak per tabel |
| `NOT NULL` | kolom wajib punya nilai |
| `CHECK` | aturan sederhana per row, misalnya `amount > 0` |
| `FOREIGN KEY` | child table harus merujuk ke row valid di parent |
| One-to-Many | satu parent, banyak child |
| Many-to-Many | butuh junction table |
| Orphan record | data child yang parent-nya tidak ada |

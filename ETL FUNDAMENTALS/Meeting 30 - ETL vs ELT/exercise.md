## Soal

Tentukan apakah pipeline A, B, dan C berikut termasuk **ETL** atau **ELT**, beserta satu kalimat alasan untuk masing-masing.

### Pipeline A

```text
CSV
 ↓
Python cleaning
 ↓
PostgreSQL
```

### Pipeline B

```text
CSV
 ↓
PostgreSQL raw_orders
 ↓
SQL transformation
 ↓
PostgreSQL orders
```

### Pipeline C

```text
API
 ↓
Python validation
 ↓
Python transformation
 ↓
PostgreSQL raw_orders
```

---

## Jawaban

### Pipeline A: ETL
**Alasan:** Data dibersihkan dengan Python terlebih dahulu, baru dimasukkan ke PostgreSQL, sehingga transformation terjadi sebelum load.

### Pipeline B: ELT
**Alasan:** Data mentah dimasukkan dulu ke `raw_orders`, lalu transformation dilakukan dengan SQL di dalam PostgreSQL setelah load.

### Pipeline C: ETL
**Alasan:** Validation dan transformation dilakukan di Python sebelum data dimuat ke PostgreSQL, sehingga transformation tetap terjadi sebelum load.

**Catatan:** Nama tabel tujuan `raw_orders` bisa menjebak. Yang menentukan ETL atau ELT bukan nama tabelnya, melainkan **di mana dan kapan transformation dilakukan**. Pada pipeline C, data sudah ditransformasi sebelum masuk ke database.

---

## Ringkasan

| Pipeline | Jawaban | Transformation dilakukan |
|----------|---------|--------------------------|
| A | ETL | di Python, sebelum load |
| B | ELT | di PostgreSQL (SQL), setelah load |
| C | ETL | di Python, sebelum load |

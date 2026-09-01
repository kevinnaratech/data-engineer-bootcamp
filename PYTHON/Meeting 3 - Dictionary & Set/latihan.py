# soal 1-Dicctionary
#Print nama produk.
#Ubah harga menjadi 7000000.
#Tambahkan key "kategori" dengan value "Elektronik".
#Kurangi stok menjadi 8.
#Print seluruh dictionary.

produk = {
    "nama": "Laptop",
    "harga": 7500000,
    "stok": 10
}
print(produk["nama"])
produk["harga"] = 7000000
produk["kategori"] = "Elektronik"
produk["stok"] = 8

print(produk)

# soal 2-.items()
# Gunakan for + .items() untuk menghasilkan:
#Andi mendapatkan nilai 80
#Budi mendapatkan nilai 90
#Caca mendapatkan nilai 75

nilai = {
    "Andi": 80,
    "Budi": 90,
    "Caca": 75
}

for key, value in nilai.items():
    print(key,f"mendapatkan nilai", value )

# soal 3-set
angka = [1, 2, 2, 3, 4, 4, 5, 5, 5]
unik = set(angka)
print(unik)

# soal 4-set operation
#Cari:
#Semua siswa dari kedua kelas.
#Siswa yang ada di kedua kelas.
#Siswa yang hanya ada di kelas A.
#Siswa yang hanya ada di kelas B.

kelas_a = {"Andi", "Budi", "Caca", "Dedi"}
kelas_b = {"Caca", "Dedi", "Eko", "Fani"}

print(kelas_a | kelas_b)
print(kelas_a & kelas_b)
print(kelas_a - kelas_b)
print(kelas_b - kelas_a)


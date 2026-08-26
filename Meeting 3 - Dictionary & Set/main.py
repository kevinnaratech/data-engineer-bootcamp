# 1.Dictionary
mahasiswa = {
    "nama": "Andi",
    "umur": 21,
    "jurusan": "Informatika",
    "nilai": [80, 90, 85]
}

print(mahasiswa["nama"])
print(mahasiswa["umur"])

# 2.Menambah dan mengubah data
mahasiswa["Gender"] = "Laki-laki"
mahasiswa["umur"] = 22

print(mahasiswa["Gender"])
print(mahasiswa['umur'])

# 3.Menghapus data
# pop() menghapus dan mengembalikan value.

umur = mahasiswa.pop("umur")

print(umur)
print(mahasiswa)

# 4.Methods

# .keys()
# Mengambil semua key:
mahasiswa.keys()

# .values()
# Mengambil semua values
mahasiswa.values()

# .item
# Mengambil pasangan key-value
mahasiswa.items()

for key, value in mahasiswa.items():
    print(key, value)

# 5. in pada dictionary
print("nama" in mahasiswa) #output (True)
print("Andi" in mahasiswa) #output (False), Karena in pada dictionary mengecek key, bukan value.
print("Andi" in mahasiswa.values()) #cek values

# 6. get() — cara aman mengambil data
print(mahasiswa.get("Alamat")) #kalau tidak ada → None.
#dikasih default
print(mahasiswa.get("Alamat", "Tidak diketahui"))

# 7. Dictionary bisa berisi struktur kompleks
print(mahasiswa["nilai"][0])

# dictionary dalam dictionary
Mahasiswa = {
    "Nama": "Andi",
    "Alamat": {
        "kota": "Surabaya",
        "kode_pos": 60200
    }
}
print(Mahasiswa["Nama"])
print(Mahasiswa["Alamat"]["kota"])

# 8. set
# collection yang menyimpan data unik

Nama = ["Andi", "Budi", "Andi", "Caca", "Budi"]

unik = set(Nama) #menghilangkan duplikat
print(unik)

# 9. Operasi Set
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

print(a | b) #union, gabungan semua elemen
print(a & b) #intersecion, elemen yang terdapat di keduan nya
print(a - b) #difference, elemen yang ada di a, tapi tidak ada di b
print(b - a) #sebaliknya


# 10. Kapan pakai apa?
#Struktur	Kegunaan
#list	    Kumpulan data berurutan, bisa berubah
#tuple	    Kumpulan data berurutan, tidak ingin diubah
#dict	    Data dengan hubungan key → value
#set	    Data unik + operasi himpunan

nilai = [80, 90, 85] #cocok list
koordinat = (10, 20) #cocok tuple
user = {
    "nama": "Budi",
    "umur": 22
}                    #cocok dict
email_unik = {"a@mail.com", "b@mail.com"} #cocok set
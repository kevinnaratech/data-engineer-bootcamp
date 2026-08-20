huruf = ["A", "B", "C", "D"]

print(huruf[0])
print(huruf[2])

# Mengubah isi list
# Karena mutable, kita bisa mengubah elemennya.

buah = ["Apel", "Jeruk", "Mangga"]
buah[1] = "Melon"

print(buah)

# Menambah data
# append()
# Menambah di belakang.

buahh = ["Apel"]

buahh.append("Jeruk")

print(buahh)

# insert()
buahhh = ["Apel", "Mangga"]

buahhh.insert(1, "Jeruk")

print(buahhh)

# extend()
# Menggabungkan list
a = [1,2]
b = [3,4]

a.extend(b)

print(a)

# remove()
# hapus berdasarkan nilai
fruit = ["Apel", "Jeruk", "Mangga"]

fruit.remove("Jeruk")

print(fruit)

#pop()
# Menghapus berdasarkan index.
angka = [10,20,30]

angka.pop(1)

print(angka)

#del()
angkaa = [1,2,3,4]

del angkaa[2]

print(angkaa)

# Panjang list
number = [10,20,30,40]

print(len(number))

# Mengecek isi list
fruitt = ["Apel","Jeruk"]

print("Jeruk" in fruitt)
print("Mangga" in fruitt)

# slicing
angka_ = [10,20,30,40,50]
print(angka_[1:4])
print(angka_[:3]) #3 angka pertama
print(angka_[2:])
print(angka_[::-1]) # membalik list

# Packing & Unpacking
point = (10,20)

x, y = point

print(x)
print(y)

#   
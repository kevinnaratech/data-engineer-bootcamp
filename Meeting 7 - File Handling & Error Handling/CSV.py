# CSV = Comma-Separated Values
#name,age,city
#Andi,20,Jakarta
#Budi,21,Bandung
#Citra,19,Surabaya

import csv 

with open("student.csv", "r") as file :
    reader = csv.reader(file)

    for row in reader:
        print(row)
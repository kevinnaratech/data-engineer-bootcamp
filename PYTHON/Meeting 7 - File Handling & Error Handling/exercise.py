# Exercise 1 — Read TXT
with open("student.txt", "r") as file:
    content = file.read()

print(content)

# Exercise 2 — Append
with open("student.txt", "a") as file:
    file.write("\nButet")

# Exercise 3 — CSV
import csv

with open("student.csv", "r") as file:
    reader = csv.reader(file)

    for row in reader:
        print(row)

# Exercise 4 — Error Handling
# The program must produce: File not found!

try:
    with open("data.csv", "r") as file:
        data = file.read()

    print(data)

except FileNotFoundError:
    print("File not found")

# Exercise 5 — JSON
import json

with open("user.json", "r")as file:
    data = json.load(file)

print(data["name"])
print(data["age"])
print(data["job"])
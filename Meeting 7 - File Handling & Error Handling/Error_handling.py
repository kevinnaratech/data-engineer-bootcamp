# What if the file doesn't exist?
try:
    with open("students.csv", "r") as file:
        data = file.read()

    print(data)

except FileNotFoundError:    
    print("File not found!")


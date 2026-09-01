with open ("data.txt", "r") as file:
    content = file.read()

print(content)

# reading file
# for example data.txt constain:
# budi
# asep
# putra
# tuyul

#output
# budi
# asep
# putra
# tuyul

# .readline()
# reading one line
with open("data.txt", "r") as file:
    line = file.readline()

print(line)

# .readlines()
# read all lines and generate a list
with open("data.txt", "r") as file:
    lines = file.readlines()

print(lines)
# ["Andi\n", "Budi\n", "Citra\n", "Doni\n"]
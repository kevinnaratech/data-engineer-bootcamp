# Exercise 1 — Basic Condition
number = int(input("number: "))

if number > 0:
    print("Positive")
elif number < 0:
    print("Negative")
else:
    print("Zero")

# Exercise 2 — Nested Condition
age = int(input("age: "))
id = input("Has ID? (yes/no): ")

if age >= 18:
    if id == "yes":
        print("You can enter")
    else:
        print("You need an ID")
else:
    print("You are too young")

# Exercise 3 — for
numbers = [10, 25, 30, 45, 50, 65]

for number in numbers:
    if number > 30:
        print(number)

# Exercise 4 — for + continue
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

for number in numbers:
    if number % 2 == 0:
        continue

    print(number)

# Exercise 5 — for + break
numbers = [10, 20, 30, 40, 50, 60]

for number in numbers:
    if number == 40:
        break

    print(number)

# Exercise 6 — while
# Create a countdown
count = 5

while count > 0:
    print(count)
    count -= 1
print("Go!")

# Exercise 7 — while + condition
#Ask the user to enter a password repeatedly.
#Correct password:
#python123
#Keep asking until the password is correct.
password = input("Password: ")

while password != "python123":
    password = input("Wrong password. Try again: ")

print("Access granted")

# Exercise 8
# Expected: [1, 4, 9, 16, ..., 100]
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
squares = []

squares = [number ** 2 for number in numbers]
print(squares)

# Exercise 9
numbers = range(1, 21)

even_number = [x for x in numbers if x % 2 == 0]
print(even_number)

# Exercise 10
words = ["python", "java", "go", "javascript", "c"]
three_char = [word for word in words if len(word) > 3 ]
print(three_char)

# Exercise 11
#Create a list where:
#even numbers → "even"
#odd numbers → "odd"
numbers = range(1, 11)

result = ["even" if x % 2 == 0 else "odd" for x in numbers]
print(result)

# Exercise 12
# Create a list containing the square of even numbers only.
numbers = range(1, 11)

squares = []

squares = [number ** 2 for number in numbers if number % 2 == 0]

print(squares)
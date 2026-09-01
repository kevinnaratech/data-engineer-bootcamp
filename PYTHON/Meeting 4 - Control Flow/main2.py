# nested condition
age = 20 
has_id = True

if age >= 18:
    if has_id:
        print("You can enter")
    else:
        print("You need an ID")
else:
    print("You are too young")

# for loop
numbers = [10, 20, 30, 40]

for number in numbers:
    print(number)

for i in range(5):
    print(i)

# while loop
count = 0

while count < 5:
    print(count)
    count += 1

# break
for number in range(10):
    if number == 5:       # When number == 5, Python hits break and exits the loop.
        break

    print (number)

# continue
for number in range(5):
    if number == 2:         # When Python reaches 2, it skips the rest of that iteration.
        continue

    print (number)

# List Comprehension

numbers = [1, 2, 3, 4, 5]

squares = []

for number in numbers:
    squares.append(number ** 2)

# You can write this Pythonically as:
squares =[number ** 2 for number in numbers]

# with a condition
numbers = range(50)
even_numbers = [x for x in numbers if x % 2 == 0]

# STRUCTURE [expression for item in iterable if condition]

# When NOT to use comprehension
# If the logic becomes complicated:
# result = [
#     complicated_expression
#     for x in data
#     if complicated_condition
# ]
# and it's becoming difficult to read, a normal for loop may be better.
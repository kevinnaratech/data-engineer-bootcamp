# def 
def say_hello():
    print("Hello!")

say_hello()

# Parameters
def greet(name):           # name is a parameter
    print(f"Hello, {name}!")
greet("Budi")
greet("Butet")

# Parameter vs Argument
# def greet(name): -----> Parameter
# greet(budi) budi -----> Argument

# 4. return
def add(a, b):
    print(a + b) #print the result  # when the function's job is specifically to display something.

def add(a, b):
    return a + b #return the result # when the function's job is to produce a value.

result = add(10,20)
print(result)

result = add(5,20) * 2
print(result)

numbers = [10, 20, 30]
result = add(numbers[0],numbers[1])
print(result)

# Multiple Values with return
def calculate (a,b):
    total = a + b
    difference = a - b

    return total, difference

total, different = calculate(10, 7)
print(total)
print(different)


# 5. Default Parameters
#Sometimes we want a parameter to have a default value.
def greet(name="Bro"):
    print(f"hello {name}!")
greet()
greet("Andi")

# Required + Default Parameters
def calculate_discount(price, discount=10):     #Required parameters should come before default parameters.
    discount_amount = price * discount / 100
    return price - discount_amount
print(calculate_discount(100000))
print(calculate_discount(100000, 20))

# 6. *args
#What if we don't know how many arguments the function will receive?
def add(*args):
    return sum(args)
print(add(1,2))
print(add(1,2,3))
print(add(1,2,3,4,5))

#What is args?
#Inside the function, args is a tuple

def show(*args):
    print(args)
show(10,20,30)

# 7. **kwargs
def show_info(**kwargs):
    print(kwargs)
show_info(name="Ando", age=20, city="Medan") #kwargs is a dictionary.

#Because it's a dictionary, we can loop through it
def show_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

show_info(
    name="Andi",
    age=20,
    city="Batam"
)


# 8. Combining Parameters, *args, and **kwargs
def example(name, age=20, *args, **kwargs):
    print(name)
    print(age)
    print(args)
    print(kwargs)

example(
    "Andi",
    21,
    "python",
    "SQL",
    city="Tanjungpinang",
    job="Student"
)

# 9. Scope — Local vs Global

# Local Variable
def greet():
    messege = "Hello"
    print(messege)
    #message exists inside the function.

# Global Variable
name = "Butet"

def greet():
    print(name)
    #The function can read the global variable:

# 10. Avoid Global Variables When Possible
def calculate_tax(price, tax):
    return price * tax
print(1000000, 0.11)
#Prefer passing data into functions instead of relying on hidden global state.

# 11. Global
count = 0

def increase():
    global count
    count += 1
increase()
increase()
increase()
print(count)

# 12. Pythonic Function Design
#Don't just learn syntax. Learn how to design functions well.

#Good function
def calculate_average(numbers):
    return sum(numbers) / len(numbers)

#Bad function
# def process_data(numbers):
#     print("Starting...")
#     total = sum(numbers)
#     average = total / len(numbers)
#     print("Average:", average)
#     numbers.sort()
#     print(numbers)
#     return average

# 13. Functions + List Comprehension
def get_even_numbers(numbers):
    return [number for number in numbers if number % 2 == 0]

numbers = [1,2,3,4,5,6]
result = get_even_numbers(numbers)
print(result)
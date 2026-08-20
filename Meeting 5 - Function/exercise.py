# Exercise 1 — Basic Function
def square(number):
    return number ** 2 
result = square(5)
print(result)

# Exercise 2 — Default Parameter
# Return the final price after discount.
def calculate_discount(price, discount=10):
    discount_amount = price * discount / 100
    return price - discount_amount

print(calculate_discount(100000))
print(calculate_discount(100000, 25))

# Exercise 3 — Statistics Function
def calculate_stats(numbers):
    total = sum(numbers)
    minimum = min(numbers)
    maximum = max(numbers)
    average = sum(numbers) / len(numbers)
    return total,minimum,maximum,average

numbers = [10, 20, 30, 40, 50]
total,minimum,maximum,average = calculate_stats(numbers)

print(f"total   :{total}")
print(f"minimum :{minimum}")
print(f"maximum :{maximum}")
print(f"average :{average}")

# Exercise 4 — *args
def calculate_total(*numbers):
    return sum(numbers)

print(calculate_total(10, 20))
print(calculate_total(10, 20, 30, 40))

# Exercise 5 — **kwargs
def display_profile(**profile):
    for key, value in profile.items():
        print(f"{key}: {value}")

display_profile(
    name="Andi",
    age=21,
    city="Tanjungpinang",
    job="Student"
)

# Challenge — Reusable Email Validator
def is_valid_email(email):   
    if "@" not in email or "." not in email:
        return False
    return  email.index("@") < email.index(".")

user = input("Email:")
print(is_valid_email(user))
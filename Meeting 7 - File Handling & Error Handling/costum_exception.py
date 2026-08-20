age = -5

if age < 0:
    raise ValueError("Age cannot be negative") #`raise` is used to intentionally trigger an exception.

balance = 100000

withdraw = 200000

if withdraw > balance:
    raise ValueError("Insufficient balance")
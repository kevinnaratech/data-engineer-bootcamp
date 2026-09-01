# if
age = 20

if age >= 18:
    print("Adult")
else:
    print("Minor")

# elif
score = 85

if score >= 90:
    print("A")
elif score >= 80:
    print("B")
elif score >= 70:
    print("C")
else:
    print("D")

# and
if age >= 18 and age <= 30:
    print("Young adult")

# or
day = "Saturday"
if day == "Saturday" or day == "Sunday":
    print("Weekend")

# not
is_raining = False

if not is_raining:
    print("Go outside")

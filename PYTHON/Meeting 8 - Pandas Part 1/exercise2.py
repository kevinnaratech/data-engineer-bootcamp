import pandas as pd

data = {
    "name": ["Andi", "Budi", "Citra", "Deni", "Eka"],
    "age": [25, 30, 22, 28, 35],
    "city": ["Jakarta", "Bandung", "Surabaya", "Medan", "Bali"]
}

df = pd.DataFrame(data)

# Exercise 9
#Get everyone whose age is greater than 25.
print(df[df["age"] > 25])

# Exercise 10
#Get everyone whose age is less than or equal to 28.
print(df[df["age"] <= 28])

# Exercise 11
#Get everyone who lives in Jakarta.
print(df[df["city"] == "Jakarta"])

# Exercise 12
#Get everyone who doesn't live in Jakarta.
print(df[df["city"] != "Jakarta"])

# Exercise 13
#Get people who are:
#age >= 28 AND city == "Bandung"
print(df[(df["age"] >= 28) & (df["city"] == "Bandung")])

# Exercise 14 🔥
#Get people who live in:
#Jakarta OR Bali
print(df[(df["city"] == "Jakarta") | (df["city"] == "Bali")])

# 
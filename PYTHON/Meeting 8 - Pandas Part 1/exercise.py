import pandas as pd

data = {
    "name": ["Andi", "Budi", "Citra", "Deni", "Eka"],
    "age": [25, 30, 22, 28, 35],
    "city": ["Jakarta", "Bandung", "Surabaya", "Medan", "Bali"]
}

df = pd.DataFrame(data)

print(df)

# Exercise 1
#Print only the name column.
print(df["name"])

# Exercise 2
#Print name and city.
print(df[["name", "city"]])

# Exercise 3
#Print the first 3 rows using head().
print(df.head(3))

# Exercise 4
# Print the last 2 rows using tail().
print(df.tail(2))

# Exercise 5
#Use info().
df.info() #age int64

# Exercise 6
#Get the first row using iloc.
print(df.iloc[0])

# Exercise 7
#Get the age of Citra using iloc.
print(df.iloc[2, 1])

# Exercise 8 — Slightly harder
#Get:
#Budi
#Bandung
#using .iloc.
print(df.iloc[1, 0])
print(df.iloc[1, 2])
print(df.iloc[1,0], df.iloc[1,2])
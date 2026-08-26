import pandas as pd

data = {
    "name": ["Andi", "Budi", "Citra", "Deni", "Eka", "Fajar"],
    "city": ["Jakarta", "Jakarta", "Bandung", "Bandung", "Jakarta", "Bandung"],
    "salary": [5000, 6000, 4500, 5500, 7000, 6500]
}

df = pd.DataFrame(data)

print(df)

df.groupby("city")["salary"].mean()
#Separate the data into groups based on city
#I'm interested in the salary column
# mean() : Calculate the average for each group

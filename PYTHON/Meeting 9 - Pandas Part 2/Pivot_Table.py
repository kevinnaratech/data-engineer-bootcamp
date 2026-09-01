#Suppose:
data = {
    "city": ["Jakarta", "Jakarta", "Bandung", "Bandung"],
    "product": ["Laptop", "Phone", "Laptop", "Phone"],
    "sales": [10, 20, 15, 25]
}

df = pd.DataFrame(data)

#We can create:
pd.pivot_table(
    df,
    values="sales",
    index="city",
    columns="product",
    aggfunc="sum"
)

#Conceptually:

#city	Laptop	Phone
#Bandung	15	25
#Jakarta	10	20

#Pivot tables are basically a convenient way to reshape and summarize data.

#Think:
#"Show me a summary where rows represent X and columns represent Y."
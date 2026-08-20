import pandas as pd

data = {
    "name": ["Andi", "Budi", "Citra"],
    "age" : [20,19,18],
    "salary": [4000000, 3000000, 2000000]
}

df = pd.DataFrame(data)

print(df)

# Selecting a Column
print(df["name"]) #one column → Series
print(df[["name", "salary"]]) #multiple columns → DataFrame.

# head()
df.head() #shows the first 5 rows
df.head(10) #first 10 row

# tail()
df.tail() #Shows the last 5 rows.
df.tail(10) #show the last 10

# info()
df.info()

#It tells you things like:

#number of rows
#column names
#data types
#missing values

#Example:

#<class 'pandas.core.frame.DataFrame'>
#RangeIndex: 3 entries, 0 to 2
#Data columns (total 3 columns):
 #   Column  Non-Null Count  Dtype
#--- ------ --------------  -----
# 0   name   3 non-null      object
# 1   age    3 non-null      int64
# 2   salary 3 non-null      int64

#Don't worry about memorizing every line.

#The important things for now:

#Column
#Non-Null Count
#Dtype

#We'll use this a LOT when cleaning datasets.

# describe()
df.describe()

#describe() gives you a quick statistical summary of numerical columns

# Reading a CSV
import pandas as pd
df = pd.read_csv("employees.csv")

print(df.head())

# Selecting Rows
# iloc → select based on position/index
print(df.iloc[0]) #get the first row
print(df.iloc[1]) #get the second row

#Multiple rows:
print(df.iloc[0:3]) #0 1 2 

# Selecting Specific Row + Column
df.iloc[0, 1] # row 0, column 1
#Example:

#        name    age
#0       Andi    25

#Then:

#df.iloc[0, 1]

#would return:
#25
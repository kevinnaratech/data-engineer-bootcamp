#Sometimes deleting data is a bad idea.

#Instead, we can fill missing values.

#For example:
df["age"] = df["age"].fillna(0)
#Missing age becomes 0.

#But that's not always logically appropriate.
#A more useful example:

df["age"] = df["age"].fillna(df["age"].mean())

#Meaning:
#Replace missing ages with the average age.
#This is called imputation.
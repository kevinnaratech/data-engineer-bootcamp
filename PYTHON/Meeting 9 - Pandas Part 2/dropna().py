#If you want to remove rows containing missing values:

df.dropna()

#Example:

#Andi   25   5000
#Budi   NaN  6000
#Citra  22   NaN
#Deni   30   5500

#After:
df.dropna()

#You get only:
#Andi   25   5000
#Deni   30   5500

#Because those rows have complete data.
#Important:
#dropna() returns a new DataFrame unless you explicitly modify the original.

#So usually:

df = df.dropna()
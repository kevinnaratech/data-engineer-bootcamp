# 1. The basic idea
#gives:

#0    25
#1    30
#2    22
#3    28
#4    35

#Now:

print(df["age"] > 25) 

#gives:

#0    False
#1     True
#2    False
#3     True
#4     True

# 2. Turning the condition into a filter
#Here's the important syntax:

df[df["age"] > 25]

#Read it almost like English:
#Give me rows from df where df["age"] > 25.

#Result:

#    name  age      city
#1   Budi   30   Bandung
#3   Deni   28     Medan
#4    Eka   35      Bali

#Notice what happened.

#The condition:

#df["age"] > 25

#created:

#False
#True
#False
#True
#True

#Then Pandas kept only the rows where the result was True.

# 3. Filtering with ==
#Suppose we want people from Jakarta.

df[df["city"] == "Jakarta"]

#Result:

#    name  age     city
#0   Andi   25  Jakarta

# 4. Other comparison operators
# >     greater than
# <     less than
# >=    greater than or equal
# <=    less than or equal
# ==    equal
# !=    not equal

df[df["age"] >= 30]

#means:
#Give me people whose age is 30 or older.

# 5. Multiple conditions
#Suppose:
#Give me people older than 25 AND from Bandung
df[(df["age"] > 25) & (df["city"] == "Bandung")]

# 6. | means OR
#People from Jakarta OR Bandung.
df[(df["city"] == "Jakarta") | (df["city"] == "Bandung")]

# 7. Why not use and / or?

#This will not work:

#df[(df["age"] > 25) and (df["city"] == "Bandung")]

# For Pandas Series, use:

# &

# instead of:

# and

# and:

# |

# instead of:

# or

# You don't need to memorize the internal reason yet. Just remember the Pandas rule.
#Real datasets can also contain duplicate rows.

#Check:

df.duplicated()

#Remove duplicates:

df = df.drop_duplicates()
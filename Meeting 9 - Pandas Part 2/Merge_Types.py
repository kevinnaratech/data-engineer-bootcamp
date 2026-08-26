#Inner
pd.merge(df1, df2, on="id", how="inner")
#Only matching records.

#Left
pd.merge(df1, df2, on="id", how="left")
#Keep everything from the left DataFrame.

#Right
pd.merge(df1, df2, on="id", how="right")
#Keep everything from the right DataFrame.

#Outer
pd.merge(df1, df2, on="id", how="outer")
#Keep everything from both.

#For now, don't memorize every detail.

#Just remember:
#merge() connects related datasets using a key.
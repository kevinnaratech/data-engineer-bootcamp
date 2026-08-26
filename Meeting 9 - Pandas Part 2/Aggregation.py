#mean() isn't the only thing we can do.

#We have:

#.mean()
#.sum()
#.min()
#.max()
#.count()

#For example:

df.groupby("city")["salary"].max()

#means:
#Maximum salary in each city.

#We can also calculate multiple things at once:

df.groupby("city")["salary"].agg(["mean", "max", "min"])

#You'll get something conceptually like:

#          mean   max   min
#city
#Jakarta   6000  7000  5000


import pandas as pd

employees = pd.DataFrame({
    "employee_id": [1, 2, 3, 4, 5, 6, 7],
    "name": ["Andi", "Budi", "Citra", "Deni", "Eka", "Fajar", "Gita"],
    "city": ["Jakarta", "Jakarta", "Bandung", "Bandung", "Jakarta", "Bandung", "Jakarta"],
    "department_id": [10, 20, 10, 20, 10, 20, 10],
    "salary": [5000, 6000, 4500, 5500, 7000, 6500, 8000]
})

departments = pd.DataFrame({
    "department_id": [10, 20],
    "department": ["IT", "Finance"]
})

df = pd.merge(employees, departments, on="department_id")


#Part A — GroupBy & Aggregation
#1. Find the average salary for each city.
#2. Find the maximum salary for each city.
#3. Find the minimum and maximum salary for each department.
#4. Calculate mean, max, and min salary for each city using one agg().

print(df.groupby("city")["salary"].mean())
print(df.groupby("city")["salary"].max())
print(df.groupby("department")["salary"].agg(["max", "min"]))
print(df.groupby("city")["salary"].agg(["mean", "max", "min"]))

# Part B — Merge
#5. Merge employees and departments using department_id.
#6. Try the same merge using: how="left"

result = pd.merge(
    employees,
    departments,
    on="department_id"
)

print(result.groupby("department")["salary"].agg(["max", "min"]))

# Part C — Pivot Table
#7. Create a pivot table where:
#rows = city
#columns = department
#values = salary
#aggregation = average

pivot = pd.pivot_table(
    result,
    index="city",
    columns="department",
    values="salary",
    aggfunc="mean"
)
print(pivot)

# Part D — Missing Values
#8. Check how many missing values each column has.
#9. Remove rows containing missing values.
#10. Fill missing age with the average age.
#11. Fill missing score with 0.
students = pd.DataFrame({
    "name": ["Andi", "Budi", "Citra", "Deni", "Eka"],
    "age": [20, None, 22, None, 21],
    "score": [80, 90, None, 75, None]
})

df = pd.DataFrame(students)

print(students.isna().sum())

print(df.dropna())

df["age"] = df["age"].fillna(df["age"].mean())
print(df)

df["score"] = df["score"].fillna(0)
print(df)

# Part E — Duplicates
#12. Check which rows are duplicates.
#13. Remove the duplicates.

data = pd.DataFrame({
    "name": ["Andi", "Budi", "Citra", "Andi", "Budi"],
    "city": ["Jakarta", "Bandung", "Jakarta", "Jakarta", "Bandung"]
})

df = pd.DataFrame(data)

print(df.duplicated())

df = df.drop_duplicates()
print(df)
# Now imagine you have two DataFrames.

employees = pd.DataFrame({
    "employee_id": [1, 2, 3],
    "name": ["Andi", "Budi", "Citra"],
    "department_id": [10, 20, 10]
})

departments = pd.DataFrame({
    "department_id": [10, 20],
    "department": ["IT", "Finance"]
})

#You have:

#employees
#employee_id | name  | department_id
#1           | Andi  | 10
#2           | Budi  | 20
#3           | Citra | 10

#And:

#departments
#department_id | department
#10            | IT
#20            | Finance

#We want:

#employee_id | name  | department
#1           | Andi  | IT
#2           | Budi  | Finance
#3           | Citra | IT

#We can use:
result = pd.merge(
    employees,
    departments,
    on="department_id"  #Use department_id as the key to match the two DataFrames
)
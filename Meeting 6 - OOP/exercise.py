# # Exercise 1
# class Student:
#     def __init__(self, name, age, grade):
#         self.name = name
#         self.age = age
#         self.grade = grade

#     def introduce(self):
#         print(f"Hi Im {self.name}. Im {self.age} years old. My grade is {self.grade}")

# student = Student("Andi", 20, "A")
# student.introduce()

# # Exercise 2
# class BankAccount:
#     def __init__(self, owner, balance):
#         self.owner = owner
#         self.balance = balance

#     def deposit(self, amount):
#         self.balance += amount

#     def withdraw(self,amount):       
#         if amount <= self.balance:
#             self.balance -= amount
#         else:
#             print("Insufficient balance")

# account = BankAccount("Jaenab", 1000000)
# account.deposit(500000)
# account.withdraw(200000)

# print(account.balance)


# # Exercise 4
# class Animal:
#     def speak(self):
#         print("Animal make a sound")

# class Dog(Animal):
#     def speak(self):
#         print("Whooff")

# animal = Animal()
# dog = Dog()

# animal.speak()
# dog.speak()

# Exercise 5 — Final OOP Challengex
class Employee:
    def __init__(self, name ,salary):
        self.name = name
        self.salary = salary

    def info(self):
        print(f"Hi, I'm {self.name}.salary Rp 10000000")

class Manager(Employee):
    def __init__(self, name, salary, departement):
        super().__init__(name, salary)
        self.department = departement

    def info(self):
        print(f"Hi im {self.name} salary {self.salary} department {self.department}" )
manager = Manager("Nara", 15000000, "Engineer")

print(f"Name       :{manager.name}")
print(f"Salary     :{manager.salary}")
print(f"Department :{manager.department}")
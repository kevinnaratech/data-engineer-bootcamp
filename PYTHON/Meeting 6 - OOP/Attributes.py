# Attributes are basically data belonging to an object.

class Student:
    def __init__(self,name,age):
        self.name = name
        self.page = age

student1 = Student("Andi", 20)
student2 = Student("Yoga", 21)

print(student1.name)
print(student2.name)
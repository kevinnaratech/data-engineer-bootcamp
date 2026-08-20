# A method is simply a function defined inside a class.

class Student:
    def __init__(self, name):
        self.name = name

    def introduce(self):
        print(f"Hi, I'm {self.name}")

student = Student("Andi")
student.introduce()
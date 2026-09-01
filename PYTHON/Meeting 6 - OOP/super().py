# Sometimes we want the child to use the parent's __init__.
class Animal:
    def __init__(self,name):
        self.name = name

class Dog(Animal):
    def __init__(self, name, breed):
        super().__init__(name)
        self.breed = breed

dog = Dog("Bobby", "Golden retriever")

print(dog.name)
print(dog.breed)
#super() basically lets us access the parent implementation.
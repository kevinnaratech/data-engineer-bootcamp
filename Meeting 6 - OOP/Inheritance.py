# We can create a child class from a parent class.

class Animal:
    def speak(self):
        print("Animal make a sound")

class Dog(Animal):
    pass
#Dog inherits from Animal.
dog = Dog()

dog.speak()
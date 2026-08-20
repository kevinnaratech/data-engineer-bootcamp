# The child can replace the parent's method.
class Animal:
    def speak(self):
        print("animal make a sound")

class Dog(Animal):
    def speak(self):
        print("Whooff")

animal = Animal()
dog = Dog()

animal.speak()
dog.speak()
#The child class provides its own implementation.
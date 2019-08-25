#!/bin/env python

class MyClass:
     """A simple example class"""
     i = 12345  # class variable shared by all instances
     def f(self):
         return 'hello world'

# Instantiate
o = MyClass()

print o.i  # attribute reference
print o.__doc__  # attribute reference
print MyClass.f(o)
# same, self is implied to be passed
print o.f()  # attribute reference
print


class MyClass2:
    def __init__(self, realpart, imagpart):
        self.r = realpart  # instance variable unique to each instance
        self.i = imagpart  # instance variable unique to each instance

o2 = MyClass2(3.0, -4.5)
print o2.r, o2.i
print



class Dog:
    species = 'k9'
    __privateimplementationdetail = 42

    def __init__(self, name):
        self.name = name
        self.tricks = []    # creates a new empty list for each dog

    def add_trick(self, trick):
        self.tricks.append(trick)

dog1 = Dog('fido')
dog1.add_trick('roll over')

dog2 = Dog('buddy')
dog2.add_trick('play dead')
dog2.add_trick('walk')

print dog1.species, dog1.tricks
###print dog2.species, dog2.tricks, dog2.__privateimplementationdetail
print



class EmployeeStruct:
    pass

john = EmployeeStruct()
 
john.name = 'Jon Doe'
john.dept = 'IT'
print john.dept

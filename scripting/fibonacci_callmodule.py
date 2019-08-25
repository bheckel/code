#!/usr/bin/env python

import fibonacci, sys

print fibonacci.fib2(100)


# If we will be using it frequently
fib = fibonacci.fib2

print fib(100)

# module's myvar will not clobber ours...
myvar = 0
print myvar
# ...unless explicit like this 
print fibonacci.myvar
# or this
from fibonacci import myvar
print myvar

print dir(fibonacci)

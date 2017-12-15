#!/usr/bin/env python
##############################################################################
#     Name: hello.py
#
#  Summary: Demo of Python
#
#           help(somefunction)
#           quit()
#
#           Adapted from https://docs.python.org/2/tutorial
#
# Modified: Mon 11 Apr 2016 13:32:49 (Bob Heckel)
##############################################################################

print 'c:\some\name'
print r'c:\some\name'

print;

print 'like echo -n', 'comma says stay on same line'

print


# Heredoc
print """\
Usage: thingy [OPTIONS]
  -h                        Display this usage message
  -H hostname               Hostname to connect to
"""

print;


print 'con' + 'catenation';

print 


word='python'
print word[0:3]
print word[3:]
print 'right'+word[-2:]

print


x = int(raw_input("Please enter an integer: "))
if x < 0:
    print 'less than zero'
elif x > 0 :
    print 'gt 0'
else :
    print 'zero'

print


wordslist = ['cat', 'dogs']
for w in wordslist :
    print w, len(w)

print


# Modify the sequence you're iterating
for w in wordslist[:] :
    wordslist.insert(0, w)

print wordslist

print


for i in range(0, 4) :
    print i
    if i % 2 == 0 :
        print "even num:", i
        continue
    print "num:", i

print


global glo
glo = 9
loc = 10

def myfunc(n):
    """Python docstring goes here.

    More goes here.
    """
    loc = 11
    print glo, loc
    print 'passed', n

    if n == 42 :
        return 'ok'

print myfunc(2)
print myfunc(42)
print myfunc.__doc__

print


def ask_ok_defaults(prompt, retries=4, complaint='Yes or no, please!'):
    while True:
        ok = raw_input(prompt)
        if ok in ('y', 'ye', 'yes'):
            return True
        if ok in ('n', 'no', 'nop', 'nope'):
            return False
        retries = retries - 1
        if retries < 0:
            raise IOError('refusenik user')
        print complaint

ask_ok_defaults('quit?', 2)

print


def cheeseshop(kind, *arguments, **keywordsdict):
    print "-- Do you have any", kind, "?"
    print "-- I'm sorry, we're all out of", kind
    for arg in arguments:
        print arg
    print "-" * 40
    keys = sorted(keywordsdict.keys())
    for kw in keys:
        print kw, ":", keywordsdict[kw]

cheeseshop("Limburger",
           "It's very runny, sir.", "It's really very, VERY runny, sir.",
           shopkeeper='Michael Palin',
           client="John Cleese",
           sketch="Cheese Shop Sketch")

print


def parrot(voltage, state='a stiff', action='voom'):
    print "-- This parrot wouldn't", action,
    print "if you put", voltage, "volts through it.",
    print "E's", state, "!"

mydict = {"voltage": "four million", "state": "bleedin' demised", "action": "VOOM"}
# Unpack dictionary
parrot(**mydict)

print


a = [66.25, 333, 333, 1, 1234.5]
# Prepend (inefficient, see deque)
a.insert(0, 42)
print a
# Push
a.append(999)
print a
# Pop
a.pop()
print a

print


# Immutable unlike lists
mytuple = 123, 456, 'hello'
print mytuple
mytuple2 = (123, 456, 'hello')
print mytuple2

print


basket = ['apple', 'orange', 'apple', 'pear', 'orange', 'banana']
# De-dup
fruit = set(basket)
# Membership test
print 'orange' in fruit

basket2 = ['grain', 'wheat', 'apple']
wheatish = set(basket2)

# in fruit but not wheatish
print fruit - wheatish
print fruit | wheatish
# apple
print fruit & wheatish
# in fruit or wheatish but not both (exclude apple)
print fruit ^ wheatish

print


# Create hash
mydict = {'jack': 4098, 'sape': 4139}
mydict['guido'] = 4127
del mydict['sape']
print mydict
print mydict.keys()
print 'guido' in mydict

mydict2 = dict(sape=4139, guido=4127, jack=4098)

print


# Iterate list
for f in basket:
###for f in sorted(basket):
###for f in sorted(set(basket)):
    print f

print 


# Iterate hash
for k, v in mydict.iteritems():
    print k, v

print


# Iterate 2 lists
questions = ['name', 'quest', 'favorite color']
answers = ['lancelot', 'the holy grail', 'blue']
for q, a in zip(questions, answers):
    print 'What is your {0}?  It is {1}.'.format(q, a)

print 


# Short-circuit default
string1, string2, string3 = '', 'Trondheim', 'Hammer Dance'
non_null = string1 or string2 or string3
print non_null

print 


# Compare sequences
print (1, 2, 3) < (1, 2, 4)

print


for x in range(1,11):
    print '{0:2d} {1:3d} {2:4d}'.format(x, x*x, x*x*x)
    print 'The story of {1}, {0}, and {other}.'.format('Bill', 'Manfred', other='Georg')

import math
print
print 'The value of PI is approximately %5.3f.' % math.pi

print


fh = open('t.txt', 'r')
###print fh.read()
print fh.readline()
print fh.readline()
fh.close()


fh = open('t.txt', 'a+')
fh.write('more appended to file\n')
fh.write('last line\n')
for line in fh:
    print 'here is:', line,
fh.close()


with open('t2.txt', 'r') as fh:
    slurp = fh.read()

print 'fh is autoclosed when using WITH\n' + slurp

print


while True:
    try:
        x = int(raw_input("Please enter a number: "))
        break
    except ValueError:
        print "Oops!  That was no valid number.  Try again..."
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise

print


import os
os.system("uptime")

import shutil
rc = shutil.copyfile('/mnt/nfs/home/bheckel/tmp/foo.txt', '/mnt/nfs/home/bheckel/tmp/bar.txt')
print rc

print


print 'tea for too'.replace('too', 'two')

# If more complicated, use regex
import re
print re.findall(r'\bf[a-z]*', 'which foot or hand fell fastest')

print


import random
print random.choice(['apple', 'pear', 'banana'])
print random.randrange(6)    # random integer chosen from range(6)

print


from datetime import date
now = date.today()
print now
print now.strftime("%m-%d-%y. %d %b %Y is a %A on the %d day of %B.")

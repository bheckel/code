#!/usr/bin/python

# Adapted: Sat Apr 30 22:17:24 2005 (Bob Heckel -- Dive Into Python Ch 7)

import re;

phonePattern = re.compile(r'''
                # don't match beginning of string, number can start anywhere
    (\d{3})     # area code is 3 digits (e.g. '800')
    \D*         # optional separator is any number of non-digits
    (\d{3})     # trunk is 3 digits (e.g. '555')
    \D*         # optional separator
    (\d{4})     # rest of number is 4 digits (e.g. '1212')
    \D*         # optional separator
    (\d*)       # extension is optional and can be any number of digits
    $           # end of string
    ''', re.VERBOSE)

print phonePattern.search('work 1-(800) 555.1212 #1234')
print phonePattern.search('work 1-(800) 555.1212 #1234').groups()
print phonePattern.search('800-555-1212')
print phonePattern.search('800-555-1212').groups()

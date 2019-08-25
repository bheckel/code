#!/bin/ruby

# Read/parse an INI file without regex gyrations

require 'Win32API'

# GetPrivateProfileString instance
getvalue = Win32API.new('kernel32', 
                        'GetPrivateProfileString',
			%w(P P P P L P), 'L');
# lstrlenA instance
strlen = Win32API.new('kernel32', 'lstrlenA', 'P', 'L');
retstr = ' ' * (255 + 1)
# Must be FQ path to INI
getvalue.Call('database', 'login', '', retstr, 255, 'c:/cygwin/home/bheckel/code/misccode/junk.ini')
length = strlen.Call(retstr)
puts retstr[0..length-1]


__END__
[database]
login = dbuser
password = foobaz
[fileshare]
username = shazbot
location = //server/path

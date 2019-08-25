#!/bin/ruby

require 'win32ole'

myie=WIN32OLE.new('InternetExplorer.Application')
myie.visible=true
###myie.navigate("http://www.gsk.com")
myie.gohome
# Attribute notation
myie.left = 0
# Hash notation
myie['top'] = 0

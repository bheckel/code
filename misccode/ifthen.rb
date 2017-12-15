#!/bin/ruby

if not (true != false) && (true != true):
  puts "Whoa! Alternate dimension!"
elsif (false === 'false') then
  puts "Type conversion? I think not..."
elsif (true == 1) or (3 == false)
  puts "Booleans != Numbers"
else
  puts "I guess we're still OK!"
end

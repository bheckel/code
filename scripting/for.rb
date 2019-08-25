#!/bin/ruby -d

a = [2,4,6,8,10,12,14]

for my_int in a
  print my_int.to_s + ", "
end

puts

# same

a.each do | my_int |
  print my_int.to_s + ", "
end

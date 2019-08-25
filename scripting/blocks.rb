#!/usr/bin/ruby

# See also yield.rb

###myarray = 'one','two','three','four'
# same
myarray = %w{one two three four}

myarray.each {|element| print "[" + element + "]" }
# same
puts
myarray.each do |element|
  print "[" + element + "]"
end;
puts

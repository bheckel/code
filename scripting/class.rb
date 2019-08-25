#!/usr/local/bin/ruby
##############################################################################
#     Name: class.rb
#
#  Summary: Demo of Ruby class features.  
#
# Adapted: Fri 26 Jul 2002 15:10:02 (Bob Heckel -- Linux Magazine April 2002)
##############################################################################

class Person
   def initialize(name, age)
      @name = name
      @age  = age
   end
   def to_s
      "#{@name}, age: #{@age}"
   end
end

p1 = Person.new("Dora",  31)
p2 = Person.new("Flora", 42)

puts p1.to_s
puts p2
puts "#{p1} and #{p2}"

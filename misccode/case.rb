#!/bin/ruby

# No fall-thru in Ruby

the_tao = 1234

case the_tao
  when 666: puts "That's such a lie!"
  when 1337
    puts "Liarrrr!"
  when 32767 then
    puts "Whatevurrrr!"
  else
    puts "You are harmonized with the Tao."
end



enlightenment = 42

case
  when enlightenment > 60:
    puts "You are too hasty, grasshopper."
  when (enlightenment < 40 or enlightenment == nil):
    puts "You are like the sloth, my friend. Diligence is key!"
  when enlightenment == 42:
    puts "Hello, Enlightened One."
  else
    puts "Yeah, not quite, pal. Maybe next time."
end

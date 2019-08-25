#!/bin/ruby

# See also for.rb

a = [ 'a', 'b', 3 ]

a.each do | elem |
  ###puts 'ok ' + elem
  # Better, doesn't break on numeric elements
  puts "ok #{elem}"
end


a.each { | elem | puts "idiomatically #{elem}" }


# Un-idiomatically (don't do this unless need to mess with i to skip elems)
i = 0
while ( i < a.length )
  print a[i].to_s + " "
  i += 1
end

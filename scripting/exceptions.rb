#!/bin/ruby -d

def method_of_doom
  my_string = "I sense impending doom."
  ###my_string.ah_ha_i_called_a_nonexistent_method
rescue NoMethodError:
  puts "You're missing that method, fool!"
rescue Exception:
  puts "Uhh...there's a problem with that there method."
else
  puts 'we are fine'
ensure
  puts 'this always prints.  good place to close files, etc.'
end
method_of_doom

#!/usr/bin/ruby
##############################################################################
#     Name: method.rb
#
#  Summary: Demo of Ruby method features.  
#
# Adapted: Fri 26 Jul 2002 15:10:02 (Bob Heckel -- hrlb.pdf)
##############################################################################

def meth(parm)
  puts 'unmodified ' + parm + ' was printed'
end

###meth('your parameter')
# same - methods always return a value
puts meth('your parameter')

def meth2(parm)
  ###return 'a', parm, 'b'
  'a'
end
puts meth2('foo')



# Default parms, first one overridden
def new_method(a = "This", b = "is", c = "fun")
  puts a + ' ' + b + ' ' + c + '.'
end
new_method('Rails')



# Variable number of parms
def print_relation(relation, *names)
  puts "My #{relation} include: #{names.join(', ')}."
end
print_relation("cousins", "Morgan", "Miles", "Lindsey")

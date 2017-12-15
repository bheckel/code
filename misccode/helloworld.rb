#!/usr/bin/ruby
##############################################################################
#     Name: helloworld.rb
#
#  Summary: Demo of basic Ruby features.  
#
#           "Ruby.  It's valium for coders©.
#           All your bases are belong to Ruby
#           Have a nice day."
#
#           Docs:
#           http://www.ruby-doc.org/core/
#           http://www.ruby-doc.org/stdlib/
#
# Adapted: Fri 26 Jul 2002 15:10:02 (Bob Heckel -- Linux Magazine April 2002)
# Modified: Fri 05 Jan 2007 16:16:21 (Bob Heckel)
##############################################################################

puts 'Hello, ' + "World. Time: #{Time.now}"


# A Ruby method:
def say_hello(name)
  puts "Hello, #{name}!"
end

say_hello "Larry"
say_hello("Moe")

puts "\n"


# Ruby arrays:
my_array = [ 42, "Hello, world!", [1,2,3] ]
my_array.push(66, 99)
my_array.insert(-1, 100)
my_array[7] = 'foo'  # force a NIL for element 6
my_array << 'this is element 8' << "and 9 is\tthe end"

puts '---'
puts my_array.fetch(10, 'uh oh element 10 not found')
puts '---'
puts my_array.values_at(0, 1, 2)
puts '---'

my_array.delete_at(0)  # remove 42
puts '---'
my_array.delete('foo')
puts my_array.delete(10) { 'still not there' }

puts "\n"




# A Ruby hash:
my_hash = {
              99 => "luft ballun",
   "seventy-six" => "trombones",
}

puts my_hash[99]
puts my_hash[76+23]
puts "The hash holds #{my_hash["seventy-six"]}"

puts "\n"

# or method-ishly
my_otherhash = Hash.new('sorry, do not have that key')
my_otherhash['foo'] = 'have it'
puts '==='
puts my_otherhash['bar']
puts my_otherhash.has_key?('foo')
puts '==='
my_otherhash.delete('foo')



# A Ruby case statement:
print "Test score: "
score = gets.to_i

case score
  when 0...40    # 3 dots is up-to-but-not-including
     puts "Back to flipping burgers"
  when 40...60
     puts "Squeaked in"
  when 60...80
     puts "Solid performance (yawn)"
  when 80...95
     puts "Wow!"
  when 95..100   # 2 dots is up-to-and-including
     puts "We are not worthy"
  else
     puts "Huh?"
end

puts "\n"

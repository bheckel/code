#!/usr/bin/ruby -d

# Simple
myproc = Proc.new {|animal| puts "I love #{animal}!"}
myproc.call("pandas")
puts



def make_show_name(show)
  Proc.new {|host| show + " with " + host}
end

show1 = make_show_name("Practical Cannibalism")

puts show1.call("H. Annabellector")
puts show1.call("Kirstie Alley")

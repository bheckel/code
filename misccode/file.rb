#!/bin/ruby

# Read:

###myfile = File.open("array.rb", "r")
# defaults to 'read'
myfile = File.open("array.rb")
myfile.each_line { |line| puts line }
myfile.close

print '-----------------'

# same
IO.foreach('array.rb') { |line| puts line }



# Write:

File.open("junk.txt", "w") do | myfile |
  myfile.write("Howdy!")
end

# same - one for the C++ programmers
File.open("junk.txt", "w") do | myfile |
  myfile << 'howdy' << "\n"
end

File.delete('junk.txt')

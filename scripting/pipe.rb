#!/bin/ruby

rb = IO.popen("ruby", "w+")
rb.puts "puts 'Whoa! Radical subprocess, dude!'"
rb.close_write
puts rb.gets

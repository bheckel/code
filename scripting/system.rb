#!/bin/ruby

system("cat /etc/passwd")
extern = `whoami`
puts ("Your username is #{extern}.")

exec("notepad") if fork.nil?
# Don't just keep going like system()
Process.wait
puts "notepad just closed"

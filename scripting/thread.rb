#!/bin/ruby

first = Thread.new() do
  myindex = 0
  while ( myindex < 10 ):
    puts "Thread One!"
    sleep 3
    myindex += 1
  end
end

second = Thread.new() do
  myindex2 = 0
  while ( myindex2 < 5 ):
    puts "Thread Two!"
    sleep 5
    myindex2 += 1
  end
end

third = Thread.new() do
  myindex3 = 0
  while ( myindex3 < 2 ):
    puts "Thread Three!"
    sleep 10
    myindex3 += 1
  end
end

first.join()
second.join()
third.join()



# Thread control

# pass() tells thread to relax for a minute and let another thread do work.
t1 = Thread.new { print "gimme a W "; Thread.pass; print "gimme a A " }
t2 = Thread.new { print "gimme a E "; Thread.pass; print "gimme a L " }
t1.join
t2.join
puts; puts 'what does it spell?  WEAL'



mate = Thread.new do
  puts "MATE: Ahoy! Can I be dropping the anchor sir?"
  Thread.stop
  puts "MATE: Aye sir, dropping anchor!"
end

Thread.pass
puts "CAPTAIN: Aye, laddy!"
mate.run
mate.join



homicide = Thread.new do
  while (1 == 1):
    puts "Don't kill me!"
    Thread.pass
  end
end

# It's usually better practice to kill a thread off from within simply because
# you know when and where it will be killed.
suicide = Thread.new do
  puts "This is all meaningless!"
  Thread.exit
end
Thread.kill(homicide)


# This is excellent for long calculations whose value isn't needed right away;
# doing them this way lets you run them on another thread so they don't
# interrupt the main thread and the execution of your program.
calculator = Thread.new { 12 / 4 * 3 }
puts calculator.value

#!/usr/bin/perl -w
# Jump Keywords (there is no break keyword).

# last 
#Jumps out of the current statement block.

# next 
#Skips the rest of the statement block and
#continues with the next iteration of the loop.

# redo 
#Restarts the statement block.

# goto 
#Jumps to a
#specified label.

# exit
# Exits immediately with the value of EXPR, which defaults to 0 (zero). 


@array = ("A".."Z");

for ($index = 0; $index < @array; $index++) {
  if ($array[$index] eq "T") {
      last;
  }
}

print("$index\n");

#This program displays:

#19

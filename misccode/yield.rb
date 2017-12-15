#!/usr/bin/ruby

# Implicit block usage:

def testyieldmeth
  print "1. Enter method. "
  yield  # NOW execute the block
  print "3. Exit method."
end
testyieldmeth { print "2. Enter block. "}

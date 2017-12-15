#!/usr/bin/ruby

def procnew
  new_proc = Proc.new { return "I got here..." }
  new_proc.call
  return "...but not here."
end
puts procnew


def lambdaproc
  new_proc = lambda { return "You get here...but it is ignored" }
  new_proc.call
  return "And I got here!"
end
puts lambdaproc

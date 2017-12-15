#!/bin/awk -f

# All arrays are associative

BEGIN {
  print "\nAccess Log Counts\n"
}

{
  if ( /^2/ )
    arr[$3]++
}

END {
  for (element in arr)
    print element, "\taccessed\t\t", arr[element], " times"
}

# junk.txt
#180607 093423	123.12.23.122 133
#180607 121234	125.25.45.221 153
#190607 084849   202.178.23.4 44
#190607 084859   164.78.22.64 12
#200607 012312	202.188.3.2 13
#210607 084849   202.178.23.4 34
#210607 121435	202.178.23.4 32
#210607 132423	202.188.3.2 167

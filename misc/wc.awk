#!/bin/awk -f

# Word count -- prints number of lines, words, characters    (18-Mar-97)
BEGIN { nf=0; nc=0 }
{ nf += NF; nc += length($0) + 2 } 
END { print NR, nf, nc }
# In real life you are better off using Unix wc command !

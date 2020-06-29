#!/bin/awk -f

# Record a 1 for each word that is used at least once.
{ for (i = 1; i <= NF; i++)
    used[$i] = 1
}

# Find number of distinct words more than 10 characters long.
END {
 for (x in used)
   if (length(x) == 18) {
     ++num_long_words
     print x
   }
    print num_long_words, "words equal to 10 characters"
}

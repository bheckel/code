#!/usr/bin/perl -w

# From command line can do this to print up to the first 'a':
# perl -0141 t.pl     <---0141 is octal 'a' (not useful for oneliners)
# if junk exists and t.pl contains 
# open FH, 'junk' or die "Error: $0: $!"; $data = <FH>; print $data;

open FILE, '<junk' or die "Error: $0: $!";

# Without next line, reads only the 1st line of FILE.
{ 
  ###local $/ = undef;   # slurp
  local $/ = 'a';   # end "line" if find an 'a'
  $data = <FILE>; 
} 
close FILE;  

# Prints entire FILE if slurped and $/ is undef
print $data;

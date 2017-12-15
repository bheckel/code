#!/usr/bin/perl -w

use warnings ;
###use strict ;
use GDBM_File ;
use vars qw( %h $k $v ) ;
unlink "fruit" ;
tie %h, "DB_File", "fruit", O_RDWR|O_CREAT, 0640, $DB_HASH 
    or die "Cannot open file 'fruit': $!\n";
# Add a few key/value pairs to the file
$h{"apple"} = "red" ;
$h{"orange"} = "orange" ;
$h{"banana"} = "yellow" ;
$h{"tomato"} = "red" ;
# Check for existence of a key
print "Banana Exists\n\n" if $h{"banana"} ;
# Delete a key/value pair.
delete $h{"apple"} ;
# print the contents of the file
while (($k, $v) = each %h)
  { print "$k -> $v\n" }
untie %h ;

#!/usr/bin/perl

use Storable;

dbmopen %DB, "junk_dbm", 0644 or die "can't dbmopen: $!";

###print "creating database...\n";
for ( 1..9 ) {
  # Won't work b/c you are trying to store an array reference
  # [ARRAY(0x12345678)] to a file which changes the reference to a string, and
  # once it becomes a string can't be changed back to a reference.
  ###$DB{"item$_"} = [ 'a', localtime ];
  $DB{ $tmp[0] } = join "\0", $_, rand(10);
  ###print "@{[ split /\0/, $DB{$tmp[0]} ]}\n";
}

###print "DEBUG: print database contents:\n";
###for ( keys %DB ) {
for ( 1..9 ) {
  print "@{[ split /\0/, $DB{$tmp[0]} ]}\n";
}

dbmclose %DB;


# Contents are still available (as .dir & .pag) w/o needed to be reloaded via
# this script.

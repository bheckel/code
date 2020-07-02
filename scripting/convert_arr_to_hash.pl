#!/usr/bin/perl -w
##############################################################################
#    Name: convert_arr_to_hash.pl
#
# Summary: Convert an array into a hash.
#
#  Created: Mon 02 Apr 2001 16:12:49 (Bob Heckel)
# Modified: Thu 10 Apr 2014 12:43:01 (Bob Heckel)
##############################################################################

# Make sure these are paired!
@arr = qw(one two thre fou fiv six);
%h = ();

$num = scalar(@arr) / 2;

for ( $i=0; $i<$num; $i++ ) {
  $key = shift @arr;
  $h{$key} = shift @arr ;
}

while ( (my $key, my $val) = each(%h) ){ print "$key=$val\n" };


print "Or if not paired:\n";

@arr2 = qw(one two thre fou fiv);
%h2 = ();
@h2{@arr2} = 0 .. $#arr2;

while ( (my $key, my $val) = each(%h2) ){ print "$key=$val\n" };

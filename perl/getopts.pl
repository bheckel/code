#!/usr/bin/perl -w
##############################################################################
#     Name: getopts.pl
#
#  Summary: Demo of using getops to handle switches.
#
#           Sample call: ./getopts.pl -h -ibob foo bar
#
#           See disconnect_timed.pl for a good short demo.
#
#  Created: Thu 21 Nov 2002 14:42:19 (Bob Heckel)
# Modified: Sun 15 Aug 2004 21:30:42 (Bob Heckel)
##############################################################################
use Getopt::Std;

# We're not going to use ARGV but here it is FYI:
print "\$#ARGV is: $#ARGV\n";  # switch is not counted right?
print "\@ARGV is: @ARGV\n";
print "\$ARGV[2] is: $ARGV[2]\n" if $ARGV[2];
print "\n";


###our($opt_h, $opt_n);
my %options;
getopts('hi:x', \%options);

while ( (my $key, my $val) = each %options ) { print "$key=$val\n" };

exists $options{h} ? One() : Two();

if ( $options{i} ) {
  print "-i parm is $options{i}\n";
}

exit 0;


sub One {
  print "switch -h is defined: $options{h}\n";
}

sub Two {
  print "switch -h is not defined\n";
}

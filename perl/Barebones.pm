##############################################################################
#     Name: Barebones.pm
#
#  Summary: Demonstrate a very simple, self-contained, class.
#
#           Test this class via: 
#           $ perl -I. -MBarebones -e 'my $b = Barebones->new()'
#
#  Adapted: Sat 02 Feb 2002 11:20:17 (Bob Heckel -- Teodor Zlatanov Road To
#                                     Better Programming IBM DeveloperWorks)
##############################################################################
package Barebones;

use strict;

# This class takes no constructor parameters.
sub new {
  my $classname = shift;  # we know our class name

  bless {}, $classname;   # and bless an anonymous hash
  print "A useless $classname object has been created.\n";
}

1;

##############################################################################
#     Name: Simple.pm
#
#  Summary: Barebones package.  Called by simple_module.pl  Probably won't
#           ever use a module this way, will use Exporter instead.
#
#  Created: Sun 15 Aug 2004 18:02:12 (Bob Heckel)
##############################################################################
package Simple;
use strict;
use warnings;

sub import {
  my $pkgname = shift;
  my $parm1 = shift;
  # ...ignoring the other parms

  print "keyword import from $pkgname: autoruns.  First parameter: $parm1\n";
}


1;

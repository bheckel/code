#!/usr/bin/perl
##############################################################################
#     Name: irename.pl
#
#  Summary: Harness for Renamer module.
#
#           ~/code/perl/irename.sh is probably better than running this
#           directly
#
#           usage: irename     # in top level dir of interest
#
#  Created: Wed 27 Oct 2004 09:48:22 (Bob Heckel)
# Modified: Wed 06 Apr 2016 09:07:31 (Bob Heckel)
##############################################################################
use warnings;

###use lib './';
use File::Irenamer;

InteractiveRename(verbose,recurse);

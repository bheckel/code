#!/usr/bin/perl -w
##############################################################################
#     Name: list_params.pl
#
#  Summary: Use the ParamFile object class to open a parameter file and list
#           its parameters and their values.
#
#  Adapted: Sat 26 Jan 2002 17:40:49 (Bob Heckel -- Mark Hewett lecture)
##############################################################################
use strict;
use ParamFile;  # no quotes for use, only for require


# Instantiate a ParamFile object...
my $pf = ParamFile->new('ifcfg-eth0');
###$pf = new ParamFile('ifcfg-eth0');
# ...an instance of ParamFile now exists.  It looks like this:
warn "$ENV{fg_yellow}DEBUG$ENV{normal}> $pf $ENV{fg_yellow}<DEBUG$ENV{normal}";
# $pf = ParamFile = HASH(0x2c857fc)
#   |
#   |_filename = ifcfg-eth0
#   |
#   |_parameters = HASH(0x2c81f58)
#          |
#          |_BOOTPRO = static
#          |
#          |_DEVICE = eth0
#          |
#          |_...
#
# This is the data structure specified by new()

# Iterate thru all parameters (i.e. PARAM = VALUE)
foreach my $param ( $pf->paramList() ) {
  # E.g. $param holds BOOTPRO here on first foreach loop.
  printf("%16s = \"%s\"\n",
          $param,
          $pf->get($param));
}

exit 0;

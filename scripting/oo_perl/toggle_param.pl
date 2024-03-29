#!/usr/bin/perl -w
##############################################################################
#     Name: toggle_param.pl
#
#  Summary: Use the ParamFile object class to open a parameter file and 
#           toggle the ONBOOT parameter's value.
#
#  Adapted: Sat 26 Jan 2002 17:40:49 (Bob Heckel -- Mark Hewett lecture)
##############################################################################
use strict;
use ParamFile;  # no quotes for use, only for require


# Instantiate a ParamFile object...
my $pf = ParamFile->new('ifcfg-eth0');
###$pf = new ParamFile('ifcfg-eth0');
# ...an instance of ParamFile now exists.  It looks like this:
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

my $onboot = $pf->get('ONBOOT');
my $newvalue = (($onboot =~ /YES/i) ? 'NO' : 'YES');
$pf->set('ONBOOT', $newvalue);
print "ONBOOT is $newvalue (see ifcfg-eth0)\n";
$pf->save();  # overwrite original ifcfg-eth0 file

exit 0;

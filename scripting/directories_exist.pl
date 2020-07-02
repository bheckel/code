#!/usr/bin/perl
##############################################################################
#     Name: directories_exist.pl
#
#  Summary: Detect any directories in PWD
#
#  Created: Fri 28 Sep 2007 09:08:14 (Bob Heckel)
##############################################################################
use warnings;

opendir DIRHANDLE, "." || die "Can't open dirhandle: $!\n";
@items = grep(!/^..?$/, readdir(DIRHANDLE));
@dirs = grep { -d } @items;
print @dirs;

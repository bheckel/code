#!/usr/bin/perl
##############################################################################
#     Name: export_module.caller.pl
#
#  Summary: Demo how to use a module that you create.  Assumes 
#           export_module.pm has been symlinked to MyModule.pm
#
#  Adapted: Thu 06 May 2004 16:49:43 (Bob Heckel -- Steve's Place Perl tut
#                                     lesson 8)
##############################################################################
use strict;
use warnings;

use MyModule;

print Hi("Perl novice");

#!/usr/bin/perl -w
##############################################################################
#     Name: simple_module.pl
#
#  Summary: Barebones use of an external package's automatic import 
#           subroutine.  Probably won't ever use a module this way so see
#           export_module.caller.p[lm]
#
#  Created: Sun 15 Aug 2004 19:41:18 (Bob Heckel)
##############################################################################
use strict;

# Simple.pm
###use Simple;
use Simple qw(PASSING THESE PARMS);

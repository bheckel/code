#!/usr/bin/perl -w
##############################################################################
#     Name: popup-messagebox.pl
#
#  Summary: Simple message box pop up.
#
#  Created: Tue 29 Jul 2003 13:44:16 (Bob Heckel)
##############################################################################
use Tk;

my $mw = MainWindow->new;
my $btn = $mw->Button(-text => 'Testing pop-up buttons', 
                      -command => \&exit);
$btn->pack;

MainLoop;

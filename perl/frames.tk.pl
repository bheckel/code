#!/usr/bin/perl -w
##############################################################################
#     Name: frames.tk.pl
#
#  Summary: Demo of using frames to force proper alignment.
#
#  Adapted: Wed 12 Nov 2003 13:05:24 (Bob Heckel -- Feb 2003 Linux
#                                     Productivity Magazine)
##############################################################################
use strict;
require 5.003;
use Tk;

my $mw = new MainWindow();

# Label is centered at top.
$mw->Label ( -text => "Just do it" ) ->pack ( -side => "top" ) ;

# Then split screen into left and right frames.
my $fleft=$mw->Frame(-background=>'#FF0000')->pack ( -side => 'left' ) ;
my $fright=$mw->Frame(-background=>'#00FF00')->pack ( -side => 'right' ) ;

#                                       to stack vertically
$fleft->Label ( -text => 'One:' ) ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -width => 1 ) ->pack ( -side => "top" , -anchor => 'w' ) ;

#                                                             right justify
$fleft->Label ( -text => 'Two:' ) ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -width => 2 ) ->pack ( -side => "top" , -anchor => 'w' ) ;

$fleft->Label ( -text => 'Three:' ) ->pack ( -side => "top" , -anchor => 'e' ) ;
$fright->Entry ( -width => 3 ) ->pack ( -side => "top" , -anchor => 'w' ) ;

MainLoop();

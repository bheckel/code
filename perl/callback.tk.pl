#!/usr/bin/perl -w
# Adapted: Tue Nov 11 14:43:58 2003 (Bob Heckel -- Feb 03 Linux Productivity
#                                    Magazine - Perl Tk)
use strict;
require 5.003;
use Tk;

# Callback subroutine.
sub printstrings (@) { 
  print "\n\n";
  foreach my $string (@_) { 
    print "$string\n";
  } 
} 

my $mw = MainWindow->new();

$mw->Button( -text => "Two strings" , 
             -command => [ \&printstrings , "Hello" , "World" ] 
           )->pack( -side => "left" )
           ;

$mw->Button( -text => "Three strings" , 
             -command => [ \&printstrings , "Hello" , "World" , "From me" ] 
           )->pack( -side => "left" )
           ;

$mw->Button( -text => "Quit" , 
             -command => sub { exit; } 
           )->pack( -side => "left" )
           ;

MainLoop();

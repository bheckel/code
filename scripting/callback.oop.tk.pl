#!/usr/bin/perl -w
use strict;
require 5.003;

package MyScreen;
use Tk;

sub new($) { 
  my $type = $_[0];
  my $self = {};

  bless ($self , $type);

  $self->{'mw'} = MainWindow->new();

  $self->{'mw'}->Button ( -text => "Two strings" , 
    -command => [ \&MyScreen::printstrings , $self , "Hello" , "World" ] ) 
    ->pack ( -side => "left" )
    ;

  ###$self-> {'mw'}->Button( -text => "Three strings" , -command => [ \&MyScreen::printstrings , $self , "Hello" , "World" , "From me" ] ) ->pack ( -side => "left" ) ;
  # Better, doesn't violate encapsulation.
  $self-> {'mw'}->Button( -text => "Three strings" , 
          -command => [ 'printstrings', $self , "Hello" , "World" , "From me" ] 
                         )->pack ( -side => "left" ) ;

    
  $self-> {'mw'}->Button ( -text => "Quit" , -command => sub { exit; } ) 
    ->pack ( -side => "left" );

  MainLoop();

  return $self;
} 

sub printstrings(@) { 
  my $self = shift;

  print "\n\n";
  foreach my $string (@_) { 
    print "$string\n";
  } 
} 

package main;

my $app = MyScreen->new();

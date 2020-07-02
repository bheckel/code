#!/usr/bin/perl -w
##############################################################################
#    Name: mandatory_response.pl
#
# Summary: Require valid user input.  Valid is loosely defined as preventing
#          user from skipping the question or putting a single dummy char in
#          place of valid input.
#
#          Works for single or multiline inputs, depending on the way the sub
#          is called.
#       
#          TODO make regex more intelligent
#
# Created: Created: Fri 23 Mar 2001 12:57:29 (Bob Heckel)
##############################################################################
use strict;

use constant DEBUG => 1;
###print mandatory_response('enter: ', 'oh no') if DEBUG == 1;
print mandatory_response('enter:') if DEBUG == 1;
my $x = mandatory_response('enter: ', 'sorry no good', 'MSG: ') if DEBUG == 2;
open(FILE, ">foo.txt") || die "$0: can't open file: $!\n" if DEBUG == 2;
print FILE $x if DEBUG == 2;


sub mandatory_response {
  my $prompt    = $_[0];
  my $errmsg    = $_[1];
  my $multiline = $_[2];

  my $msgline = undef;

  $errmsg ||= 'Invalid response.  Please try again.';

  print "$prompt ";
  chomp(my $response = <STDIN>);

  # Minimal checking. Require any response except a carriage return or a
  # single character at the first prompt.
  ($response = undef) if $response =~ /^.$/;

  if ( $multiline ) {
    until ( $response ) {
      print "$errmsg\n$prompt: ";
      chomp($response = <STDIN>);
      ($response = undef) if $response =~ /^.$/;
    }
    $msgline = "$multiline$response\n";
    # Possibly have more lines from user.
    while ( $response ) {
      print '> ';
      chomp($response = <STDIN>);
      if ( $response ) {
        $msgline .= "$multiline$response\n";
      }
    }
  } else {
    # Single line.  E.g. simply obtain name that is not blank or a single
    # char.
    until ( $response ) {
      print "$errmsg\n$prompt ";
      chomp($response = <STDIN>);
      ($response = undef) if $response =~ /^.$/;
    }
  }

  $msgline ? return $msgline : return $response;
}

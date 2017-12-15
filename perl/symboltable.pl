#!/usr/bin/perl -w
##############################################################################
#     Name: symboltable.pl
#
#  Summary: Hacking on the symbol table.
#
#  Adapted: Fri 30 Apr 2004 15:58:10 (Bob Heckel --
#                               http://www.steve.gb.com/perl/lesson04.html)
##############################################################################
# use strict;

$zpibble = 2;
@zfoo = ( 1, 4 );
%zbits = ( me => 'so tired' );
sub zmy_sort { return ( $a cmp $b ) }

# Perl's symbol table is just a hash, %main::
foreach ( sort keys %main:: ) {
  print "symbol (scalar, array, hash, sub or something else): $_.\n";
}

print "\n\nThis program contains (values are typeglobs)...\n";
while ( my ( $key, $value ) = each %main:: ) {
  # This assigns the value from the symbol table to a typeglob.
  local *symbol = $value;

  # These lines look to see if the typeglob contains a $, %, @ or &
  # definition.
  if ( defined $symbol ) {
    print "a scalar called \$$key in $value\n";
  }

  if ( defined @symbol ) {
    print "an array called \@$key in $value\n";
  }

  if ( defined %symbol ) {
    print "a hash called \%$key in $value\n";
  }

  if ( defined &symbol ) {
    print "a subroutine called $key in $value\n";
  }
}

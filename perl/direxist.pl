#!/usr/bin/perl -w

$openyr{NAT} = [ 2004 .. 2005 ];
$openyr{MOR} = [ 2003 .. 2005 ];
$openyr{FET} = [ 2003 .. 2005 ];
$openyr{MED} = [ 2003 .. 2005 ];

while ( (my $k, my $v) = each %openyr ) { 
  for $y ( @$v ) {
    for $e ( 'mvds', 'register' ) {
      if ( -e "/u/dwj2/$e/$k/$y" ) {
        print "ok $e $k $y \n";
      } else {
        print "$e $k $y not found!\n";
      }
    }
  }
}

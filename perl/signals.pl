#!/usr/bin/perl -w

sub catch_zap {
  my $signame = shift;
  die "Somebody sent me a SIG$signame!";
} 

$shucks = 0;
$SIG{INT} = 'catch_zap';   # always means &main::catch_zap
$SIG{INT} = \&catch_zap;   # best strategy
$SIG{QUIT} = \&catch_zap;  # catch another, too

while ( 1 ) {
  # do nothing
}

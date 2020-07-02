#!/usr/bin/perl -w

while ( 1 ) {
  print STDERR 'Password: ' if !$foo;
  print STDERR 'you again? passport:' if $foo;
  $foo = <STDIN>;
  chomp $foo;
  print STDERR "move along $foo\n";
  exit if $foo eq 'exit';
  sleep 5;
}

print 'ended normally';

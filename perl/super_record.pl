#!/usr/bin/perl
##############################################################################
#     Name: super_record.pl
#
#  Summary: This looks a bit like an Object...
#
#  Adapted: Tue 30 Oct 2007 13:20:19 (Bob Heckel --
#                                      http://perldoc.perl.org/perldsc.html)
##############################################################################
use strict;
use warnings;

my $string = 'foo str';
my @old_values = ('a', 'b', 'c');
my %some_table = ( 'mykey' => 'my val', 'mykey2' => 'my val2' );
sub some_function { print "$_[0] me\n"; return 'i am ok'; }


my $rec = {
  TEXT      => $string,
  SEQUENCE  => [ @old_values ],
  LOOKUP    => { %some_table },
  THATCODE  => \&some_function,
  THISCODE  => sub { $_[0] * $_[1] },
  HANDLE    => \*STDOUT,
};


print $rec->{TEXT};

print $rec->{SEQUENCE}[0];
my $last = pop @{ $rec->{SEQUENCE} };
print $last;

print $rec->{LOOKUP}{mykey};
my ($first_k, $first_v) = each %{ $rec->{LOOKUP} };
print $first_k, $first_v;

my $arg = 'hello';
my $answer = $rec->{THATCODE}->($arg);
print $answer;

my ($arg1, $arg2) = (5, 10);
$answer = $rec->{THISCODE}->($arg1, $arg2);
print $answer;

# careful of extra block braces on fh ref
print { $rec->{HANDLE} } "a string\n";

use FileHandle;
$rec->{HANDLE}->autoflush(1);
$rec->{HANDLE}->print(" and another string\n");

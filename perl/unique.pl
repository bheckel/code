#!/usr/bin/perl -w

# Modified: Fri 08 Aug 2003 16:30:32 (Bob Heckel)

use strict;

my @list = qw(h a b a c d d e f g f h h);

# 1.  Extract unique, non duplicate elements from a list.
my %seen = ();
my @unique = ();
foreach my $item ( @list ) {
  unless ( $seen{$item} ) {
    # if we get here, we have not seen it before
    $seen{$item} = 1;
    push(@unique, $item);
  }
}
print "1. @unique\n";


# 2.  Faster
%seen = ();
@unique = ();
foreach my $item ( @list ) {
  push(@unique, $item) unless $seen{$item}++;
}
print "2. @unique\n";


# 3. Slightly different.
%seen = ();
@unique = ();
foreach my $item (@list) {
  $seen{$item}++;
}
@unique = keys %seen;
print "3. @unique\n";


# 4.  Using grep
%seen = ();
@unique = ();
@unique = grep { ! $seen{$_}++ } @list;
print "4. @unique\n";
# or modify original array:
%seen = ();
@list = grep { ! $seen{$_}++ } @list;


# 5.  Only duplicate (i.e. 2 or more) elements.
#        _ _   _   _ _   _   _ _ _
#     qw(h a b a c d d e f g f h h);
%seen = ();
@unique = ();
@unique = grep { ++$seen{$_} == 2 } @list;
print "5. @unique\n";


# 6.  Best or just the most obfuscated (it *is* memory intensive)?
my @uniq = keys %{ { map {$_ => 1} @list } };
print "6.  @uniq\n";

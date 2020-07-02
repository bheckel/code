#!/usr/bin/perl -w
##############################################################################
#     Name: reference_dereference.pl
#
#  Summary: Reference & dereferencing.
#
#           The way to read @{ $arrayref } is 'the array referred to by
#           $arrayref'.
#
#  Created: Mon 11 Nov 2000 11:13:10 (Bob Heckel)
# Modified: Tue 04 May 2004 10:58:19 (Bob Heckel)
##############################################################################

my $thingy = {
    name =>
    {
        fore => "Steve",
        sur  => "Cook"
    },
    age => sub { (localtime)[5] + 1900 - 1965 }
};

# References can be dereferenced by chasing pointers:
print $thingy->{name}->{fore}, $thingy->{age}->(), "\n"; # or equivalently
###print $thingy->{name}{fore}, $thingy->{age}(), "\n";

# Or accessed using the block syntax:
print values %{ $thingy->{name} };

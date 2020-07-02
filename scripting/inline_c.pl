#!/usr/bin/perl -w
##############################################################################
#     Name: inline_c.pl
#
#  Summary: Compile C code to run under Perl.
#
#           TODO figure out perl's SV, HV, AV...
#
#           First
#           $ export PERL_INLINE_DIRECTORY=/tmp 
#
# Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place lesson 14)
##############################################################################
use strict;
use Inline 'C';

chomp(my $name = <STDIN>);

my $size = Count($name);

print "Your name is $size letters long\n";

__END__
__C__

#include <string.h>

int Count(char *name) {
  int length = strlen(name);

  return length;
}

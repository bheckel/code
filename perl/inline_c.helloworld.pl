#!/usr/bin/perl -w
##############################################################################
#     Name: inline_c.pl
#
#  Summary: Compile C code under Perl.
#
#           First
#           $ export PERL_INLINE_DIRECTORY=/tmp 
#
# Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place lesson 14
##############################################################################
use strict;
use Inline 'C';


hello();

__END__
__C__
int hello() {
  printf("Hello, world\n");
  exit(0);
}

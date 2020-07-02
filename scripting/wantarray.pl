#!/usr/bin/perl
##############################################################################
#     Name: wantarray.pl
#
#  Summary: Demo of context awareness using wantlist.
#
#  Adapted: Mon 04 Apr 2011 16:12:44 (Bob Heckel -- Modern Perl chromatic)
##############################################################################
use strict;
use warnings;

sub context_sensitive {
  my $context = wantarray();
  print 'Called in void context' unless defined $context;
  return'Called in scalar context' unless $context;
  return qw(Called in list context) if $context;
}

###context_sensitive();
###print my $scalar=context_sensitive();
print context_sensitive();

#!/usr/bin/perl -w

# Demo of swapping colon-delimited columns.
# Adapted: Wed, 23 Feb 2000 17:28:48 (Bob Heckel--Perl Myths article on
#                                     perl.com)

# Must pass a filename (must :se ff=unix the incoming file(s))
while (<>) {
  s/(.*):(.*)/$2:$1/;
  print;
}

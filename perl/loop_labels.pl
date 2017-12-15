#!/usr/bin/perl -w
##############################################################################
#     Name: loop_labels.pl
#
#  Summary: Use loop labels to jump out of loops.
#
#  Adapted: Tue 04 May 2004 14:17:59 (Bob Heckel -- Steve's Place tut Ch 07)
##############################################################################
use strict;

###open FH, 'junk' or die "Error: $0: $!";

LINE: while ( <DATA> ) {
  s/[\r\n]+$//;
  my @arr = split /\s+/, $_;
  WORD: for my $word ( @arr ) {
    # ignore the rest of the line, it's only a comment
    next LINE if $word =~ /^#/;
    # ignore the rest of the lines if you find Perl's __END__ token
    last LINE if $word =~ /QUITME/;
    # don't print anything rude
    next WORD if $word =~ /rude/;
    print "ok: $word\n";
  }
}

__DATA__
here is
random junk
# skip me
for the
code ok
to use
insert rude comment here
Probably should save as 'junk'
QUITME
now

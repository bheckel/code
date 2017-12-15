#!/usr/bin/perl;
#####################################################################
#    PROGRAM: emoticon.pl
#    PURPOSE: Driver for the Emoticon.pm module for illustrating simple
#             objected-oriented  Perl.
#     AUTHOR: Steve A. Chervitz (sac@genome.stanford.edu)
#     SOURCE: http://genome-www.stanford.edu/~sac/perlOOP/examples/
#    CREATED: 1 July 1997
#   MODIFIED: sac --- Wed Aug 20 15:52:26 1997
#    ADAPTED: Wed, 17 May 2000 15:05:34 (Bob Heckel)
#####################################################################

use Emoticon();
use strict;
use Data::Dumper;
use diagnostics;

###my $emoticon1 = new Emoticon();
my $emoticon1 = new Emoticon(face=>'8^]');
print Dumper($emoticon1);
###printf "EMOTICON 1: %s\n\n", $emoticon1->emote;
###printf "EMOTICON 2: %s\n\n", $emoticon2->emote;

$emoticon1->frown;
$emoticon1->mouth('>');

###printf "EMOTICON 1 FROWNING: %s\n\n", $emoticon1->emote;
###$emoticon1->smile;
printf "EMOTICON 1 %s\n\n", $emoticon1->emote;
print "xxxxxxxx\n";
$emoticon1->printface();
###printf "EMOTICON 2 WITH NEW MOUTH: %s\n\n", $emoticon2->emote;

###exit();

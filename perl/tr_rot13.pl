#!/usr/bin/perl
##############################################################################
#     Name: tr_rot13.pl
#
#  Summary: Transliteration.  ROT13 encryption.
#           Use vim's visualize then g? to unscramble.
#
#           If the same character occurs more than once in SEARCHLIST, only the
#           first is used. Therefore, this:
#
#           tr/AAA/XYZ/
#
#           will change any single character A to an X (in $_).
#
#
#           Won't do variable interpolation but you can use this:
#
#           eval "tr/$oldlist/$newlist/";
#
#  Created: Mon 21 Sep 2009 10:10:39 (Bob Heckel)
##############################################################################
###use strict;
use warnings;

$rotate13 = 'foobar';

#                  ______ ____________  NOT regexes!
###$rotate13 =~ tr/a-zA-Z/n-za-mN-ZA-M/ ;
# Same
###$rotate13 =~ y/a-zA-Z/n-za-mN-ZA-M/;
# Same!
###$rotate13 =~ y(a-zA-Z)(n-za-mN-ZA-M);
# Same!!
$rotate13 =~ y<a-zA-Z> :n-za-mN-ZA-M:;
# Does not work
###$rotate13 =~ s/a-zA-Z/n-za-mN-ZA-M/;

print $rotate13, "\n";

$rotate13 =~ tr/aeiou/!/;  # change any vowel into !
print $rotate13, "\n";


#!/usr/bin/perl -w
##############################################################################
#     Name: eval_do.pl
#
#  Summary: Demo of sourcing external Perl code.
#
#  Created: Tue 22 May 2001 11:04:19 (Bob Heckel)
##############################################################################

$tmpfile = 'junk';
%release = ();

$release{'bobh'} = 'foo';
print "Before, rel 456 is: $release{'456'}\n";
eval "do $tmpfile";
print "After, rel 456 is: $release{'456'}\n";

__END__
junk:

$release{'456'} = "103";
$release{'555'} = "102";
$release{'666LX'} = "101";
1;

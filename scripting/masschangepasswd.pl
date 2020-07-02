#!/usr/bin/perl
##############################################################################
#     Name: masschangepasswd.pl
#
#  Summary: Mass update users to a single new password.  Created to conform
#           to CDC 60 day password rotation requirements.
#
#  Adapted: Fri 27 Aug 2004 16:33:27 (Bob Heckel -- Randall Schwartz)
# Modified: Mon 10 Jan 2005 09:23:43 (Bob Heckel)
##############################################################################
use warnings;

die "usage: $0 passwordstring\n" if ! $ARGV[0];

$newpass = $ARGV[0];
@ARGV = ("/etc/shadow");
$^I = ".bak"; # creates /etc/shadow.bak, just in case
srand(time|$$); # spin the dials
$uids='alm5|bhb6|bqh0|bxj9|ces0|ckj1|cmc6|cwt4|dwj2|ekm2|hdg7|kjk4|mbj1|pyh9|rev2|slm6|vdj2';

while ( <> ) {
  next if !/^($uids):/;
  $seed = &Seedchar.&Seedchar;
  $cryptpass = crypt($newpass, $seed);
  s/^(\w+):[^:]+:/$1:$cryptpass:/;
} continue {
  print;
}

sub Seedchar {
  ('a'..'z','A'..'Z','0'..'9','.','/')[rand(64)];
}

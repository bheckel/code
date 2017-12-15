#!/usr/bin/perl -w
##############################################################################
#     Name: ipnum2name.pl
#
#  Summary: Convert an IP address to its hostname.
#
#  Adapted: Thu 31 Jan 2002 20:33:30 (Bob Heckel -- Blue Camel examples)
##############################################################################

print numtoname('207.202.214.131');

sub numtoname {
  local($_) = @_;

  unless ( defined $numtoname{$_} ) {
    local(@a) = gethostbyaddr(pack('C4', split(/\./)),2);
    $numtoname{$_} = @a > 0 ? $a[0] : $_;
  }

  $numtoname{$_};          
}

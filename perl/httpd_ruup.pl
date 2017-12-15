#!/usr/bin/perl -w
##############################################################################
#     Name: httpd_ruup.pl
#
#  Summary: Detect if webserver is ok.  Cron runs this every minute and it
#           arranges for me to get mail when Apache was restarted (because the
#           init scripts have output). As a nice side effect, this way I get
#           lots of mail when the nameserver is broken :)
#
#  Adapted: Sat 08 May 2004 06:08:01 (Bob Heckel -- Juerd on PerlMonks)
##############################################################################
use strict;
use LWP::Simple;

exit 0 if -e "/etc/nouptest";

eval {
  local $SIG{ALRM} = sub { die "Alarm\n" };
  alarm 10;
  my $p = get 'http://uptest.convolution.nl/';
  $p =~ /xyzzy/ or die "Down\n";
  alarm 0;
};

if ( $@ ) {
  if ( $@ =~ /Alarm|Down/ ) {
    system qw[/etc/init.d/apache stop];
    sleep 3;
    system qw[killall -9 apache];
    sleep 3;
    system qw[/etc/init.d/apache start];
  }
}

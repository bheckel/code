#!/c/Perl/bin/perl -w 
##############################################################################
#     Name: detect_dirchanges.pl
#
#  Summary: Monitor directory for changes to files.
#
#           ActiveState Perl only!  Don't even think about running it from
#           Unix!
#
#           TODO when run as a Service, perl.exe does not terminate on Stop
#
#  Created: Tue 29 Jul 2003 13:45:54 (Bob Heckel)
##############################################################################
use strict;
use Win32::ChangeNotify;
use Mail::Sendmail qw(sendmail %mailcfg);
$|++;

$mailcfg{debug} = 6;
$mailcfg{retries} = 8;
$mailcfg{delay} = 1800;  # every 30 min

###my $path = 'c:/tmp/diffdir';
###my $path = 'K:\ORKAND\System Documentation';
my $path = 'I:\CABINETS\TSB\EXCEL\MIS02';
my $subtree = 0;
my $events = 'LAST_WRITE';
my $t = undef;
my $notify = undef;
my %mail = ();
my $run = 9000000000;  # init high enough to always run on first iteration
my $lastrun = undef;
my $tmpf = "$ENV{TMP}/detect_dirchanges.tmp.dat";

# Hard to tell what is running when using Services.  This gives proof that the
# code has at least started.
open FH, ">$tmpf" or die "Error: $0: $!";
print FH "$0 started ", scalar(localtime);
close FH;

while ( 1 ) {
  $notify = Win32::ChangeNotify->new($path, $subtree, $events);
  $notify->wait or warn "a Win32::ChangeNotify error has occurred\n";

  $t = scalar(localtime);
  $run = time;
  ###print "run: $run\n";
  ###print "lastrun: $lastrun\n";
  my %mail = ( To         => 'bqh0@cdc.gov',
               From       => 'bheckel@cdc.gov',
               Subject    => "$path change detected at $t",
               Message    => "Please note: $0 running on $ENV{COMPUTERNAME} " .
                             'as Windows Service "WatchDir" has noticed ' .
                             'file(s) changes.',
               Importance => 'High',
             );
  # Limit number of possible emails to 1 per hour.
  ###if ( ($run - $lastrun) > 3600 ) {
  if ( ($run - $lastrun) > 90 ) {
    sendmail(%mail) or warn $Mail::Sendmail::error;
  }
  ###print "Log:\n", $Mail::Sendmail::log, "\n";

  $notify->reset;
  $notify->close;

  $lastrun = time;
}



=head1 NAME

detect_dirchanges.pl  --  monitor a directory for changes to existing files.

=head1 DESCRIPTION

Should be run as a Windows Service with a hardcoded path to the directory of
interest.

=cut

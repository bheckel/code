#!/usr/bin/perl -wT
##############################################################################
#     Name: choose_cgi.pl
#
#  Summary: Process web logfile based on button clicked by user.
#
#           See webstats.pm webstats.pl ck_tstamp.pm
#
#           May need to increase httpd.conf timeout if the ftp transfer speed
#           is too slow.
#
#  Created: Tue 18 Feb 2003 12:50:02 (Bob Heckel)
# Modified: Wed 09 Jul 2003 08:38:03 (Bob Heckel -- allow separator that is
#                                     not a dot '.')
# Modified: Wed 28 Jan 2004 10:54:04 (Bob Heckel -- reword pw warnings)
# Modified: Mon 24 May 2004 12:40:30 (Bob Heckel -- improve security)
##############################################################################
use Scalar::Util qw(tainted);
use lib ".";

delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};   # make %ENV safer

my $PW = 'cdc';

# ------------------ Begin HTTP/1.0 Standard Header -------------------------
$|++;
print "Content-type: text/plain\n\n";

my $buf = undef;
if ( $ENV{'QUERY_STRING'} eq "" && $ENV{'CONTENT_LENGTH'} ) {
  read STDIN, $buf, $ENV{'CONTENT_LENGTH'};
} elsif ( $ENV{'QUERY_STRING'} && !$ENV{'CONTENT_LENGTH'}) {
  $buf = $ENV{'QUERY_STRING'};
}

# Number of name/value pairs passed in.
my $argc_pairs = 0;	
my @pairs = split '&', $buf;

my %FORM = ();
foreach my $pair ( @pairs ) {
  my ($name, $value) = split '=', $pair;
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  $argc_pairs++;
}
# ------------------------ End Standard Header ----------------------------


use strict qw(refs vars);
use ck_tstamp;
use webstats;

if ($FORM{the_pw} =~ /^([-\@\w.]+)$/) {
  $FORM{the_pw} = $1;  # attempt to untaint user input
}

if ( tainted($FORM{the_pw}) ) {
  if ( $FORM{the_pw} eq '' ) {
    print "Error: password is required\n";
    die "$0 empty password was passed from $ENV{REMOTE_ADDR}\n" 
  } else {
    print "Insecure data detected.  Your address, $ENV{REMOTE_ADDR}, has " .
          "been logged.";
    die "$0 tainted data ($FORM{the_pw}) was passed from $ENV{REMOTE_ADDR}\n" 
  }
}

if ( $FORM{the_pw} ne $PW ) {
  print "Error: password \'$FORM{the_pw}\' not recognized from " .
        "$ENV{REMOTE_ADDR}\n";
}


if ( $FORM{button_ck} ) {
  my $server = 'webstats.cdc.gov';
  my $serverdir = 'www2a/'. $FORM{the_year};
  my $conn = undef;

  $conn = Connect($server);
  List($conn, $serverdir, $server);
  Quit($conn);
} 
elsif ( $FORM{button_run} ) {
  # Toggle when debugging.  This is the most time-intensive part.  The prior
  # run's .zip stays in the tmp dir.
  ###GetZip($FORM{the_year}, $FORM{the_zipfile});
  Unzip();
  Process($FORM{the_textbox}, $FORM{the_year}, $FORM{the_spacer});
  Cleanup();
}
else {
  print "unknown web interface error";
  die "$0 unknown web interface error";
}

exit 0;

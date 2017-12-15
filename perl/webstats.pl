#!/usr/bin/perl
##############################################################################
#     Name: webstats_if.pl
#
#  Summary: Web interface to the formerly command line app, webstats.pl
#
#           See webstats.pm webstats_if.pl choose_cgi.pl
#        
#  Created: Fri Dec 20 13:46:48 2002 (Bob Heckel) 
# Modified: Wed 09 Jul 2003 08:38:03 (Bob Heckel -- allow separator that is
#                                     not a dot '.')
# Modified: Wed 21 Jan 2004 12:44:37 (Bob Heckel -- added 2004 radio button)
##############################################################################
use strict;
use CGI::Carp qw(fatalsToBrowser set_message);

$|++;

# Time stamp the last modified date on the resulting webpage.
my $mtime = (stat($0))[9];
my $t = localtime $mtime;

# ------------------ Begin HTTP/1.0 Standard Header -------------------------
print "Content-type: text/html\n\n";

my $buf = undef;
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

PrintForm();

# Footer.
print <<"EOT";
  </FONT><FONT SIZE=-2><BR>Please contact Bob Heckel at 
  <A HREF=mailto:bheckel\@cdc.gov?Subject=ioquery.pl>bheckel\@cdc.gov</A> 
  if you have any questions.
  <BR>Last updated: $t</FONT>
</BODY></HTML>
EOT

exit 0;



sub PrintForm {
  # Using POST since no bookmarking of links, etc. will be needed.
  print <<"EOT";
  <HTML>
  <HEAD>
    <TITLE>NCHS VSCP Web Traffic Statistics</TITLE>
  </HEAD>
  <BODY BGCOLOR="#FFF8DC">
    <CENTER>
      <U><H3>National Center for Health Statistics, RTP, NC</U></H3>
    </CENTER>
    <FORM ACTION="choose_cgi.pl" METHOD="POST">
      <BR>Password:
      <INPUT NAME="the_pw" TYPE="password">
      <BR>
      <BR>
      <BR>
      <H3>Check to see if latest zip file is ready:</H3>
      <INPUT NAME="the_year" TYPE="radio" VALUE="2002">Year 2002
      <INPUT NAME="the_year" TYPE="radio" VALUE="2003">Year 2003
      <INPUT NAME="the_year" TYPE="radio" VALUE="2004" CHECKED>Year 2004
      <INPUT NAME="button_ck" TYPE="submit" VALUE="Check webstats.cdc.gov">
      <BR><BR>
      <H3>If it is, enter the desired filename:</H3>
      <INPUT NAME="the_zipfile" TYPE="textbox">
      <BR><BR>
      <H3>And title for month:</H3>
      <INPUT NAME="the_textbox" TYPE="text">
      <BR><BR>
      <H3>And desired single character output spacer:</H3>
      <INPUT NAME="the_spacer" TYPE="text" VALUE="." SIZE="3">
      (use a space if parsing with another application, otherwise a 
      period or dash works well)
      <BR><BR><BR><BR>
      <INPUT NAME="button_run" TYPE="submit" VALUE="Begin Processing">
      This will take anywhere from 5 to 60 minutes to complete.
    </FORM>
EOT
}

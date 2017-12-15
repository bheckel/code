#!/usr/bin/perl -w
##############################################################################
#     Name: search4files.cgi
#
#  Summary: Search NCHS user's web dirs for TSA PDFs, turning search results
#           into hyperlinks.
#
#  Created: Fri 26 Mar 2004 14:56:46 (Bob Heckel)
# Modified: Wed 01 Sep 2004 17:01:44 (Bob Heckel)
# Modified: Tue 05 Oct 2004 14:21:44 (Bob Heckel -- only find *.PDF not .pdf)
# Modified: Tue 18 Jan 2005 13:53:07 (Bob Heckel -- eliminate bqh0 files from 
#                                     search)
##############################################################################
use strict;
use File::Find;
$|++;
my $DEBUG = 0;

# ------------------ Begin HTTP/1.0 Standard Header -------------------------
print "Content-type: text/html\n\n";

my $buf = "";
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

use constant IP => '158.111.250.37';
# TODO use an external file for easy maintenance
my @dirs = qw{
  /home/kjk4/public_html
  /home/ekm2/public_html
  /home/bhb6/public_html
  /home/hdg7/public_html
  /home/rev2/public_html
  /home/vdj2/public_html
  /home/bxj9/public_html
  /home/dwj2/public_html
  /home/alm5/public_html
  /home/pyh9/public_html
  /home/cmc6/public_html
  /home/slm6/public_html
  /home/ckj1/public_html
  /home/mbj1/public_html
  /home/ces0/public_html
};

# NCHS TSA PDFs from our user's public_html dirs.
my @PDFS = ();  # GLOBAL! used by find()
find(\&Fnd, @dirs);

$FORM{the_st} ||= '\w\w';
$FORM{the_yr} ||= '\d\d';
$FORM{the_ship} ||= '\d+';
$FORM{the_evt} ||= '\w';
print "DEBUG st: $FORM{the_st}\n" if $DEBUG;
print "DEBUG yr: $FORM{the_yr}\n" if $DEBUG;
print "DEBUG ship: $FORM{the_ship}\n" if $DEBUG;
print "DEBUG evt: $FORM{the_evt}\n" if $DEBUG;
my @results = Match(\@PDFS, $FORM{the_st}, $FORM{the_yr}, $FORM{the_ship}, 
                    $FORM{the_evt});

# Hash will hold URL and timestamp.
my %links = GenHyperlink(\@results);

#############
# Print page:

# Don't confuse the user by displaying a regex.
$FORM{the_ship} = ($FORM{the_ship} eq '\d+') ? '*' : $FORM{the_ship};

# Make user friendly.
if ( $FORM{the_evt} eq 'N' ) { 
  $FORM{the_evt} = 'Natality';
}
elsif ( $FORM{the_evt} eq 'M' ) { 
  $FORM{the_evt} = 'Mortality';
}
elsif ( $FORM{the_evt} eq 'F' ) { 
  $FORM{the_evt} = 'Fetal Death';
}
elsif ( $FORM{the_evt} eq 'T' ) { 
  $FORM{the_evt} = 'Medical';
}
else {
  print "ERROR.  Please contact LMITHELP";
}
print <<"EOT";
<H3><CENTER>
Search Results for $FORM{the_st} $FORM{the_yr} $FORM{the_ship} $FORM{the_evt}
</H3>
<FONT FACE="courier new">
<BR></CENTER>
EOT

print "<BR>Sorry, no files found.<BR>" if ! keys(%links); 


my $n = 0;
my $c;
print "<TABLE>\n";
foreach my $key (sort { $links{$b} cmp $links{$a} } keys %links) {
  # Alternate colors every other row for readability.
  (($n++ % 2) == 0) ? ($c = '#C1FFB1') : ($c = '#CAE1FF');
  my $lt = localtime $links{$key};
  print "<TR><TD BGCOLOR=$c>TSA: $key Created: $lt</TR>\n";
}
print "</TABLE>\n";


print <<'EOT';
<BR><BR><INPUT TYPE="button" VALUE="< Back" onClick="history.go(-1)">
EOT

exit 0;
#############


#############
# Subs

# Coderef for File::Find.
sub Fnd {
  # We're using lowercase pdf for debugging projects.
  m/\.PDF$/ and push @PDFS, $File::Find::name;
}


# Based on user input, determine which of the files match the regex.
sub Match {
  my $r_arr = shift;
  my $st = shift;
  my $yr = shift;
  my $ship = shift;
  my $evt = shift;

  my $regex = $st . $yr . $ship . $evt;
  print "DEBUG regex: $regex<BR>" if $DEBUG;

  my @tmp = grep { /$regex/ } @$r_arr;

  return @tmp;
}


# Turn the filename into a hyperlink and determine timestamp info.
sub GenHyperlink {
  my $r_arr = shift;

  my %h = ();
  my $lnk;

  for my $f ( @{$r_arr} ) {
    ($lnk = $f) =~ s!/home/(\w\w\w\d)/public_html/(.*)!<A HREF=http://@{[IP]}/~$1/$2>$2</A>!;
    $h{$lnk} = (stat($f))[9];
  }

  return %h;
}

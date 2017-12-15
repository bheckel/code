#!/usr/pkg/bin/perl -w

# Modified: Sun 05 Apr 2009 10:34:01 (Bob Heckel)

my $DEBUG = 0;
my $TMPF = 'npTMP.htm';  # used by ~/bin/ckdate.pl
my $F = 'np.htm';

# ----------------------- Begin Standard Header ---------------------------
# Trap errors.  Send to browser.
BEGIN {
  # Print out a content-type for HTTP/1.0 compatibility.
  print "Content-type: text/html\n\n";
  open(STDERR, ">&" . STDOUT) or die "Cannot Redirect STDERR: $!";
}

# Get form data via GET or POST methods.
if ( $ENV{'QUERY_STRING'} eq "" && $ENV{'CONTENT_LENGTH'} ) {
  print "Getting FORM (i.e. POST method) input...<P>" if $DEBUG;
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}); 
  $ENV{'CONTENT_LENGTH'} = 0;
} elsif ( $ENV{'QUERY_STRING'} && !$ENV{'CONTENT_LENGTH'}) { 
  print "Getting URL (i.e. GET method) input...<P>" if $DEBUG;
  $buffer = $ENV{'QUERY_STRING'}; 
} else {
  print "Direct access via link<BR>";
}

# Number of name/value pairs passed in.
$argc_pairs = 0;	
# Split the name-value pairs.
@pairs = split(/&/, $buffer) if $buffer;

foreach $pair ( @pairs ) {
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  $argc_pairs++;
}

# ------------------------ End Standard Header ----------------------------


# TODO fix untaint to avoid "Use of uninitialized value $1 in concatenation (.) or string at np.pl line 50. Use of uninitialized value $1 in concatenation (.) or string at np.pl line 50. "
# Print table of name/value pairs if any have been passed in.
if ( $argc_pairs ) {
  open FILE, ">>$TMPF" || die "$0: can't open file: $!\n";
  ###$FORM{myposttextbox} =~ /(.*)/;  # untaint
  if ( $FORM{myposttextbox} =~ /^http/ ) {
    ###$cleaninput = '<A HREF=' . $1 . '>' . $1 . "</A><BR>\n";
    $cleaninput = "<A HREF='" . $FORM{myposttextbox} . "'>" . $FORM{myposttextbox} . "</A><BR><BR>\n";
    print $cleaninput;
  } else {
    $cleaninput = "$FORM{myposttextbox}<BR><BR>\n";
    print "$FORM{myposttextbox}";
  }
  # Minimize vandalism.
  print FILE $cleaninput if length $cleaninput < 8192;
  close FILE;
}

open FILE, "$TMPF" || die "$0: can't open file: $!\n";
open FILEREVERSE, "+<$F" or die "Error: $0: $!";

print FILEREVERSE "<HTML><HEAD><TITLE>np.htm</TITLE></HEAD><BODY>";
print FILEREVERSE q!<LINK REL=stylesheet TYPE="text/css" HREF="np.css"> <BODY background="a_Cakka.gif">!;
print FILEREVERSE q!<style type="text/css" media="screen">body { background-attachment: fixed; } </style>!;
print FILEREVERSE reverse <FILE>;

close FILE;
close FILEREVERSE;

print "<BR><BR><B>Environment Variables<BR>" if $DEBUG;
MakeTbl(\%ENV) if $DEBUG;

print <<"EOT";
<HTML><HEAD><TITLE>np.pl</TITLE></HEAD><BODY><LINK REL=stylesheet TYPE="text/css" HREF="np.css"> <BODY background="a_Cakka.gif"><style type="text/css" media="screen">body { background-attachment: fixed; } </style>
<FORM ACTION="http://bheckel.sdf.org/np.pl" METHOD="POST" NAME="mypostform">
  <INPUT NAME="myposttextbox" TYPE="text" VALUE="">
  <INPUT NAME="mypostsubmit" TYPE="submit">
</FORM>
<BR>
<BR>
</BODY>
</HTML>
EOT

exit 0;



# Produce an HTML table from a hash.
sub MakeTbl {
  my ($r) = @_;

  print "<TABLE BORDER='1'>\n";
  while ( ($name,$value) = each %$r ) { 
    print "<TR><TD>$name<TD>$value\n"; 
  }
  print "</TABLE>\n";

  return 0;
}

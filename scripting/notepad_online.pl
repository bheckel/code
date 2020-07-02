#!/usr/pkg/bin/perl

# Assuming this is ~/html/cgi-bin/notepad_online.pl and httpd.conf has been
# configured properly, call it this way from the browser:
# http://localhost/cgi-bin/notepad_online.pl

# Modified: Thu 15 May 2003 12:59:24 (Bob Heckel)

my $DEBUG = 0;
my $TITLE = 'Notepad Online';

# ----------------------- Begin Standard Header ---------------------------
# Trap errors.  Send to browser.
BEGIN {
  # Print out a content-type for HTTP/1.0 compatibility.
  print "Content-type: text/html\n\n";
  print "<HTML><HEAD><TITLE>$TITLE</TITLE></HEAD><BODY>";
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
  print "Explicitly using neither POST nor GET methods.<BR>";
  print "Implicitly using GET method.<BR>";
}

# Number of name/value pairs passed in.
$argc_pairs = 0;	
# Split the name-value pairs.
@pairs = split(/&/, $buffer);

foreach $pair ( @pairs ) {
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  # The special variable $1 is always set to whatever was
  # matched between the parens ( ) of the first pattern, and the hex
  # operator converts that hexadecimal notation back to a regular decimal
  # number. That number then becomes the argument of the pack command. In
  # this case pack basically looks up that number in the ASCII table and
  # returns the appropriate US_ASCII character.
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $Form{$name} = $value;
  $argc_pairs++;
}

# ------------------------ End Standard Header ----------------------------

# Print table of name/value pairs if any have been passed in.
if ( $argc_pairs ) {
  open(FILE, ">>./notepad.dat.html") || die "$0: can't open file: $!\n";
  if ( $Form{myposttextbox} =~ /^http/ ) {
    # Untaint.
    $Form{myposttextbox} =~ /(.*)/;
    $cleaninput = "<A HREF=$1>$1</A><BR>\n";
  } else {
    $Form{myposttextbox} =~ /(.*)/;
    $cleaninput = "$1<BR>\n";
  }
  # Avoid vandalism.
  print FILE $cleaninput if length $cleaninput < 1024;
  close(FILE);
} else {
  print "No values passed to this page.";
}

# Print table of Unix environment variables.
print "<BR><BR><B>Environment Variables<BR>" if $DEBUG;
# The Perl 4 Way.
###makeTbl(*ENV);
makeTbl(\%ENV) if $DEBUG;

print <<EOT;
<FORM ACTION="$ENV{SCRIPTFILENAME}" METHOD="POST" NAME="mypostform">
  <INPUT NAME="myposttextbox" TYPE="text" VALUE="" SIZE='60'>
  <INPUT NAME="mypostsubmit" TYPE="submit">
</FORM>
EOT

###print "<A HREF='http://localhost/bheckel/notepad.dat.html'>View</A></BODY>" .
print "<A HREF='http://bheckel.multics.org/notepad.dat.html'>View</A></BODY>" .
      "</HTML>\n";

exit 0;


# Produce an HTML table from a hash.
sub makeTbl {
  # The Perl 4 Way.
  ###local(*array) = @_;
  my($rarray) = @_;

  print "<TABLE BORDER='1'>\n";
  while ( ($name,$value) = each %$rarray ) { 
    print "<TR><TD>$name<TD>$value\n"; 
  }
  print "</TABLE>\n";

  return 0;
}

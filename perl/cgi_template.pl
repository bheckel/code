#!/usr/bin/perl
##############################################################################
#     Name: cgi_template.pl
#
#  Summary: Perl CGI template
#
#           Also see iocode_qry.pl for a good demo
#           or webstats_if.pl for a simple demo. 
#
#       Try calling it this way: http://emiake/cgi-bin/cgi_template.pl
#       or http://localhost/cgi-bin/cgi_template.pl
#       or http://localhost/cgi-bin/cgi_template.pl?foo=bar
#       or http://localhost/cgi-bin/cgi_template.pl?foo=bar&x=y
#       or http://localhost/cgi-bin/cgi_template.pl/pathinf?foo=bar
#
#  Adapted: Fri, 11 Aug 2000 13:08:10 (Bob Heckel -- Mark Hewett's code)
# Modified: Wed 23 Jul 2003 12:14:15 (Bob Heckel)
##############################################################################
use constant DEBUG => 1;

# ----------------------- Begin Standard Header ---------------------------
# Content-type for HTTP/1.0 compatibility.
print "Content-type: text/html\n\n";

my $buf = undef;
# Getting STDIN FORM (i.e. POST method) input.
if ( $ENV{QUERY_STRING} eq "" && $ENV{CONTENT_LENGTH} ) {
  read STDIN, $buf, $ENV{'CONTENT_LENGTH'}; 
} elsif ( $ENV{QUERY_STRING} ne "" && !$ENV{CONTENT_LENGTH}) { 
  # Getting URL (i.e. GET method) input.
  $buf = $ENV{QUERY_STRING}; 
}

if ( $ENV{HTTP_COOKIE} ) {
  @pairs = split(/;/, $ENV{HTTP_COOKIE});
  foreach $pair ( @pairs ) {
    if ( $value =~ /[&`'\\"|\*?~><\^\(\)\{\}\[\]\$\n\r]/ ) { 
      die "Insecure data passed into script.\n"; 
    }
    ($name, $value) = split(/=/, $pair);
    # De-webify '+' and '%' URL encoding.
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    # Disallow subshells to execute commands.
    $value =~ s/~!/ ~!/g;
    print "Setting $name to $value...<BR>" if DEBUG;
    $FORM{$name} = $value;
  }
}

# Number of name/value pairs passed in.
$argc_pairs = 0;	
@pairs = split /&/, $buf;

my %FORM = ();
foreach $pair ( @pairs ) {
  my ($name, $value) = split /=/, $pair;
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  $argc_pairs++;
}
# ------------------------ End Standard Header ----------------------------

print '<HTML><HEAD><TITLE>cgi_template</TITLE></HEAD><BODY>';

# Print table of name/value pairs if there are any.
if ( $argc_pairs ) {
  print "<B>Name/Value Pairs:</B><BR>\n";
  MakeTbl(\%FORM);
} else {
  print "No values passed to this page yet.";
}

# Print table of Unix environment variables.
print "<BR><BR><B>Environment Variables:<BR>";
MakeTbl(*ENV);

print <<EOT;
<BR>
<FORM ACTION="$ENV{SCRIPT_NAME}" METHOD="POST" NAME="mypostform">
  <INPUT NAME="myposttextbox" TYPE="text" 
   VALUE="Will be submitted via REQUEST_METHOD POST" SIZE=60>
  <BR><BR>
  <INPUT TYPE=checkbox NAME=ckbox1 VALUE=foo1>fooone value
  <INPUT TYPE=checkbox NAME=ckbox2 VALUE=foo2>footwo value
  <BR><BR>
  <INPUT NAME="mypostsubmitbutton" TYPE="submit">
</FORM>
</BODY></HTML>
EOT

exit 0;


sub MakeTbl {
  my $ref = shift;

  print "<TABLE BORDER=1 CELLSPACING=1>\n";
  while ( ($name, $value) = each %{$ref} ) { 
    print "<TR><TD>$name<TD>$value\n"; 
  }
  print "</TABLE>\n";
}

#!/usr/bin/env perl

# See msgform.html (calls this code).

use constant DEBUG => 1;
use constant HTMLTITLE => "Robert S. Heckel Jr. Message Submission";

# ----------------------- Begin Standard Header ---------------------------
# Print out a content-type for HTTP/1.0 compatibility.
print "Content-type: text/html\n\n";
print '<HTML><HEAD><TITLE>' . HTMLTITLE . '</TITLE></HEAD><BODY>';

# Get form data via GET or POST methods
if ( $ENV{'QUERY_STRING'} eq "" && $ENV{'CONTENT_LENGTH'} ) {
  print "Getting FORM (i.e. POST method) input...<P>" if DEBUG;
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}); 
} elsif ( $ENV{'QUERY_STRING'} && !$ENV{'CONTENT_LENGTH'}) { 
  print "Getting URL (i.e. GET method) input...<P>" if DEBUG;
  $buffer = $ENV{'QUERY_STRING'}; 
} elsif ( $ENV{'QUERY_STRING'} && $ENV{'CONTENT_LENGTH'}) { 
  print "Getting both<P>" if DEBUG;
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'}); 
} else {
  print "Using neither POST nor GET methods.<BR>";
}

# Number of name/value pairs passed in.
$argc_pairs = 0;	
# Split the name-value pairs.
@pairs = split(/&/, $buffer);

foreach $pair ( @pairs ) {
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $FORM{$name} = $value;
  $argc_pairs++;
}

if ( $ENV{HTTP_COOKIE} ) {
  print "Getting Cookies input<P>" if DEBUG;
  @pairs = split(/;/, $ENV{HTTP_COOKIE});
  foreach $pair ( @pairs ) {
    if ( $value =~ /[&`'\\"|\*?~><\^\(\)\{\}\[\]\$\n\r]/ ) { 
      die "Insecure data passed into script.\n"; 
    }
    ($name, $value) = split(/=/, $pair);
    # De-webify '+' and '%' URL encoding.
    $value =~ tr/+/ /;
    # See EOF for details on this beast.
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    # Disallow subshells to execute commands.
    $value =~ s/~!/ ~!/g;
    print "Setting $name to $value...<BR>" if DEBUG;
    $FORM{$name} = $value;
  }
}
# ------------------------ End Standard Header ----------------------------


###open(MAIL, "|/usr/sbin/sendmail robertheckel\@solectron.com") 
  ###                                           || HTMLdie('no open');

###print MAIL "Submitted from $0: $FORM{name} and $FORM{message}";

close MAIL;

if ( DEBUG ) {
  while ( (my $key, my $val) = each(%FORM) ) { 
    push @formdata, "$key=$val<BR>";
  }
}

# Performed above:  print "Content-type: text/html\n\n";  so not needed here.
print <<"EOF" ;
<HTML>
<HEAD>
  <TITLE>HTMLTITLE</TITLE>
    <STYLE TYPE="text/css">
      .sectheaders {
        color: #005500;
        letter-spacing: 2px;
        font-weight: bold;
      }
    </STYLE>
</HEAD>
<BODY BGCOLOR="FFFFEA">
  <CENTER>
  <P CLASS="sectheaders">Your message has been sent.</P>
  <H3>Thanks.</H3>
  <INPUT TYPE="button" VALUE="Back to Resume" 
   onClick = "javascript:history.go(-2)">
  </CENTER>
  <!--   DEBUG information, if any. -->
  @formdata
</BODY>
</HTML>
EOF

# Die, outputting HTML error page.  If no $title, use a default title.
sub HTMLdie {
  my ($msg, $title)= @_;

  $title || ($title= "CGI Error from HTMLdie()");

  print <<"EOF" ;
Content-type: text/html

<html>
<head>
<title>$title</title>
</head>
<body>
<h1>$title</h1>
<h3>$msg</h3>
</body>
</html>
EOF

  exit ;
}

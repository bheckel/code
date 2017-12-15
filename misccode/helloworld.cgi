#!/usr/bin/perl -w

BEGIN {
  print "Content-type: text/html\n\n";
}

$color = 'red';

$cgi_arg = $ENV{'QUERY_STRING'};

if ( $cgi_arg =~ /color=(.*)/ ) { 
  $color = $1; 
}

$date = localtime(time);

print <<"END";
<HTML>
<HEAD>
  <TITLE>The time is now</TITLE>
</HEAD>
<BODY><H3>The time is:</H3>
  <FONT COLOR="$color"><CENTER><H1>$date</H1></CENTER></FONT>
</BODY>
</HTML>
END

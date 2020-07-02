#!/usr/bin/perl
# Perl Cookie Maniplution
# (c) 1996 Noel Hunter (noel@camelcity.com) http://www.camelcity.com
# This free software; you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free 
# Software Foundation; either version 2, or (at your option) any later version.

sub getinput {
# Getinput takes STDIN from a form, the URL, and cookies and turns it 
# into usable perl variables placed in the array $FORM.  
# Subroutine originally based on FORM-MAIL package by Reuven M. Lerner 
# (reuven@the-tech.mit.edu).
	
	print "Getting FORM input<P>" if $debug;
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 	binmode(STDIN);
	# Split the name-value pairs
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs)
	{
		($name, $value) = split(/=/, $pair);
	  	# Un-Webify plus signs and %-encoding
  		$value =~ tr/+/ /;
   		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   		# Stop people from using subshells to execute commands
   		$value =~ s/~!/ ~!/g;
		print "Setting $name to $value<BR>" if $debug;
   		$FORM{$name} = $value;
	}

	print "Getting URL input<P>" if $debug;
	@pairs = split(/&/, $ENV{'QUERY_STRING'});
	foreach $pair (@pairs)
	{
		($name, $value) = split(/=/, $pair);
	  	# Un-Webify plus signs and %-encoding
  		$value =~ tr/+/ /;
   		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   		# Stop people from using subshells to execute commands
   		$value =~ s/~!/ ~!/g;
		print "Setting $name to $value<BR>" if $debug;
   		$FORM{$name} = $value;
	}

	print "Getting Cookies input<P>" if $debug;
	@pairs = split(/;/, $ENV{HTTP_COOKIE});
	foreach $pair (@pairs)
	{
		($name, $value) = split(/=/, $pair);
	  	# Un-Webify plus signs and %-encoding
  		$value =~ tr/+/ /;
   		$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
   		# Stop people from using subshells to execute commands
   		$value =~ s/~!/ ~!/g;
		print "Setting $name to $value<BR>" if $debug;
   		$FORM{$name} = $value;
	}
}

sub setcookie{
	# Encode spaces, semicolons, and commas
	$cookievalue =~ "s/ /%20/g"; 
	$cookievalue =~ "s/;/_/g"; 
	$cookievalue =~ "s/,/_/g"; 

	# Set the cookie counter (0) to new value
	print "Set-Cookie: ExampleCookie=${cookievalue}\n";
}

# Main Program #

$debug=0;

print "Content-type: text/html\n";	# Start the HTTP headers
&getinput;				# Get Form, URL, and Cookie input

if ($FORM{'setcookie'}) {		# If we got a setcookie variable,
	$cookievalue=$FORM{'setcookie'};# then set the cookie to it
	&setcookie;
}
print "\n\n";				# End HTTP headers

print <<END;
<BODY BGCOLOR="#FFFFFF" TEXT="#000000" LINK="#B08000" VLINK="#808080" 
ALINK="#0077FF">
<CENTER>
END

open (H, "../logo.htm");
while (<H>) {
        print $_;
}

print <<END;
<h3>Sample Cookie, Form, and URL Input Script</h3>
</CENTER>

This script demonstrates handling input to CGI scripts in a convenient and
consistent way.  All of the Form, URL, and Cookie input is processed and placed
into an array.  To send information to this script, use one of
the following methods:<P>

1. Use a FORM input field, and POST the form.<P>
2. Use a URL query string when retreiving this script.  For example,
call the script as:<BR>
<code>    http://www.camelcity.com/example-cgi/cookie.cgi?example=a</code>
<BR>
to set a variable called "example" equal to "a"<P>
3. Use a cookie.  To set a cookie, call this script with the query 
string "setcookie=value".  For example:<BR>
<code>http://www.camelcity.com/example-cgi/cookie.cgi?setcookie=a</code>
<BR>
will set the ExampleCookie equal to a.  This script only uses one cookie
as an example.  By changing the source code, you can assign other cookie
values as needed.

<HR>
END

open (H, "../ad.htm");
while (<H>) {
        print $_;
}

print <<END;
<H3>Here are all the Form, URL, and Cookie values passed into this script:</H3>
END

# Print out all the Form, URL and Cookie inputs from the Form array:
@keys = keys %FORM;
foreach $key ( sort { $a <=> $b } keys %FORM ) {
	print "$key=$FORM{$key}<BR>\n";
}

# Print out our environment:
print "<HR><H3>Here is our environment:</H3><PRE>" . `env` . "</PRE>";

# All done.

print <<END;
<HR>
<CENTER>
<A HREF="cookie.txt">Source code for this script</A><BR>
END

open (H, "../footer.htm");
while (<H>) {
        print $_;
}

print <<END;
</CENTER> 
END

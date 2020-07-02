#!/usr/local/bin/perl
##############################################################################
#
# ABOUT:
#
# This is a simple Perl CGI that does exactly two things.
#   o Generate an HTML file based on form input and predefined header and
#     footer HTML.
#   o Email the webmaster to inform him/her of the existance of the new
#     document.
#
#
# SETUP:
#
# Follow the instructions below and you should be all set. If you're
# having trouble, feel free to drop me a line.
#   o Save this script, upload it to your web server, and make sure it
#     has permissions set to 755 (rwxr-wr-w). This should be in a
#     password protected space. Users must be authenticated _before_ this
#     script is executed. 
#   o Write an HTML document with a form to send the data. For an
#     example, see http://friedo.rh.rit.edu/free/mkpgform.html
#   o Set the variables below to the appropriate values.
#   o Modify the print<< block below the parse code to output your custom
#     headers and footers.
#   o Have fun!
#
#
# CREDITS:
#
# The code for parsing the POST input stream was shamelessly stolen from
# "CGI 101" at http://www.cgi101.com/class/ch4/text.html
#
# All the rest was written by me, Mike Friedman, who can be reached at 
# mnf7228@osfmail.rit.edu or http://friedo.rh.rit.edu/
#
##############################################################################


#### Useful variables. Set these to the appropriate values. Remember to
#### escape the @'s in email addresses with a backslash.

# Email address of the webmaster
$wmemail = "mnf7228\@osfmail.rit.edu";

# "From" address for email
$fmemail = "nobody\@friedo.rh.rit.edu";

# location of sendmail. Type 'which sendmail' at the shell prompt if
# you don't know where it is.

$sendmail = "/usr/bin/sendmail";

# Full path to new files dir (no slash at the end)
$newdir = "/web/httpd/htdocs/free/new";

# URI of new files dir (pathname as it appears to web browser)
$newdiruri = "/free/new";




# parse POST stream and clean up icky URL characters

read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
@pairs = split(/&/, $buffer);
foreach $pair (@pairs) {
    ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $FORM{$name} = $value;
}

###########################################
# modify the HTML output below to add your customized headers and footers
###########################################

# open filehandle and print the stuff to it
open (NEWFILE, ">$newdir/$FORM{'filename'}");

print NEWFILE <<HTML;
<html>
<head>
<title>$FORM{'title'}</title>
</head>

<!--#include virtual="/ssi/head.txt"-->

<h2>$FORM{'title'}</h2>

$FORM{'text'}

<!--#include virtual="/ssi/foot.txt"-->

HTML

close (NEWFILE);

# report back to the user
print <<END;
Content-type: text/html\n
<html>
<head>
<title>Yeehaw!</title>
</head>

<body>
<h2>It worked!</h2>
To see the page you just made, click <a
href="$newdiruri/$FORM{'filename'}">here</a>. <br>

END

# finally, email the webmaster to inform him of the update

open (MAIL, "|$sendmail -t");

print MAIL <<EndMail;
To: $wmemail
From: $fmemail
Reply-To: $fmemail
Subject: Web update!

$FORM{'email'}

Filename: $FORM{'filename'}


EndMail

close (MAIL);


# that's all, folks


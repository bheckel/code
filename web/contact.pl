#!/usr/bin/perl
# Modified: 18-Aug-2025 (Bob Heckel)
# export REQUEST_METHOD=POST && export CONTENT_LENGTH=21 && echo "emssage=CLI%20test%20message" | perl contact.pl

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use MIME::Lite;

my $q = CGI->new;

my $email   = $q->param('email')   || '';
# Typo to discourage bots
my $emssage = $q->param('emssage') || '';

# Clean up whitespace
# $emssage =~ s/^\s+|\s+$//g;

my $body = <<"END_MSG";
Email: $email

Message:
$emssage
END_MSG

my $msg = MIME::Lite->new(
    From    => 'webserver@rshdev.com',
    To      => 'rsh@rshdev.com',
    Bcc     => 'bheckel@gmail.com',
    Subject => 'rshdev.com website inquiry',
    Data    => $body
);

 if (length($emssage) > 1) {
   $msg->send;
 }

# Output confirmation page
print $q->header('text/html');
print <<"HTML";
<!DOCTYPE html>
<html>
<head>
<title>Message Sent</title>
</head>
<body bgcolor=#43b0e0>
<h2>...sent!</h2>
<p>We will reply to your message in 3 days or less</p>
</body>
</html>
HTML

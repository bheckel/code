#!/usr/bin/perl
# Modified: 16-Aug-2025 (Bob Heckel)

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use MIME::Lite;

my $q = CGI->new;

my $email   = $q->param('email')   || '';
my $message = $q->param('message') || '';

my $body = <<"END_MSG";
Email: $email

Message:
$message
END_MSG

my $msg = MIME::Lite->new(
    From    => 'webserver@rshdev.com',
    To      => 'bheckel@gmail.com,rsh@rshdev.com',
    Subject => 'rshdev.com website inquiry',
    Data    => $body
);

if (defined $body && $body ne '') {
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
<body bgcolor=#0ea5e9>
<h2>...sent!</h2>
<p>We will reply to your message in 3 days or less</p>
</body>
</html>
HTML

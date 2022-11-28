#!/usr/bin/perl

use strict;
use warnings;

print "Content-type: text/html\n\n";
foreach my $key (keys %ENV) {
    print "$key --> $ENV{$key}<br>";
}


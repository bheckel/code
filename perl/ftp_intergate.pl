#!/usr/bin/perl -w

use strict;

use Net::FTP;

my $ftp = Net::FTP->new('intergate.com',
                        Debug   => 1,
                        Timeout => 100) 
                              || die "Can't connect: $@. $?. $!. Exiting.\n"
          ;

$ftp->login('heckels', 'randa1j');
$ftp->hash(1);
$ftp->put("$ENV{HOME}/index.html", 'public_html/junk.html');
###$ftp->delete('junk.html');
$ftp->quit || warn "Not a graceful quit.  May indicate a problem.\n";


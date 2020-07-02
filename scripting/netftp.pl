#!/usr/bin/perl -w

use strict;

use Net::FTP;

my $ftp = Net::FTP->new('mirrors.rcn.net',
                        Debug   => 1,
                        Timeout => 100) 
                              || die "Can't connect: $@. $?. $!. Exiting.\n"
          ;

$ftp->login('anonymous', 'bheckel@gmail.com');
$ftp->hash(1);
$ftp->get('/pub/sourceware/cygwin/setup.ini', 'setup.ini');
$ftp->quit || warn "Not a graceful quit.  May indicate a problem.\n";


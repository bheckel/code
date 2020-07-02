#!/usr/bin/perl -w

# Not working b/c coreutils is not in coreutils/ on the server.

use strict;
use Net::FTP;

my $cygmirror = '/mirrors/sources.redhat.com/cygwin';

my $ftp = Net::FTP->new('mirrors.rcn.net',
                        Debug   => 1,
                        Timeout => 100) 
                              || die "Can't connect: $@. $?. $!. Exiting.\n"
          ;

$ftp->pasv;
$ftp->login('anonymous', 'bheckel@gmail.com');
$ftp->hash(1);
###$ftp->get('/pub/sourceware/cygwin/setup.ini', 'setup.ini');

open FH, 'setup.ini' or die "Error: $0: $!";
my @paragraphs;

{           
  local $/ = '';
  @paragraphs = <FH>;
}

foreach my $paragraph ( @paragraphs ) {
  if ( $paragraph =~ /category: Base/ ) {
    # Pick off the line that has the path we need
    $paragraph =~ /install: (\S*)/;
    my $instline = $1;
    $instline =~ /(\S+\/)(.*)/;
    my $path = $1;
    my $fname = $2;
    print "$1 and $2\n";
    $ftp->cwd("$cygmirror/$path") || die "can't cd to $cygmirror/$path";
    $ftp->get($fname) || die "can't get $fname";;
  }
}

$ftp->quit || warn "Not a graceful quit.  May indicate a problem.\n";


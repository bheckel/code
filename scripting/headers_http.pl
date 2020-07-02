#!/usr/bin/perl

# One liner:
# $ perl -MLWP::UserAgent -e '$u=new LWP::UserAgent;$r=$u->head;print $r->{_rc}'

# Must install HTML-Tagset-3.10.tar.gz, HTML-Parser-3.56.tar.gz, URI-1.35,
# then libwww-perl-5.805.tar.gz answering Y to everything (2007-02-28)
use LWP::UserAgent;

###my $URL = $ARGV[0] || 'http://rtpsawn321/links/';
my $URL = $ARGV[0] || 'http://gsk.com';

print "Fetching $URL ...\n";

$ua = new LWP::UserAgent;
$ua->proxy(['http', 'ftp'], 'http://setproxy.gsk.com/proxy.pac');

$res = $ua->head;

use Data::Dumper; print Dumper $res;
print "\n\n\n";
print "http status code is " . $res->{_rc};

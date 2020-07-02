#!/usr/bin/perl

# Must install HTML-Tagset-3.10.tar.gz, HTML-Parser-3.56.tar.gz, URI-1.35,
# then libwww-perl-5.805.tar.gz answering Y to everything (2007-02-28)
use LWP::UserAgent;

my $URL = $ARGV[0] || 'http://rtpsawn321/links/';
# Probably need proxy http://setproxy.gsk.com/proxy.pac before going external
###my $URL = $ARGV[0] || 'http://gsk.com';
print "Fetching $URL ...\n";

$ua = new LWP::UserAgent;
$req = new HTTP::Request 'GET' => "$URL";
$res = $ua->request($req);

if ( $res->is_success ) {
  print ($res->content);
  printf "fetched %d bytes\n", length($res->content);
} else {
  print "Error: " . $res->code . " " . $res->message;
}



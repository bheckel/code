#!/usr/bin/perl -w
# userstats - generates statistics on who is logged in.
# call with an argument to display totals

use DB_File;

$db = 'userstats.db';       # where data is kept between runs

tie(%db, 'DB_File', $db)         or die "Can't open DB_File $db : $!\n";

@who = `who`;

if ( $? ) {
  die "Couldn't run who: $?\n";
}

# extract username (first thing on the line) and update
foreach $line (@who) {
  $line =~ /^(\S+)/;
  die "Bad line from who: $line\n" unless $1;
  $db{$1}++;
}

while ( (my $key, my $val) = each(%db) ) { print "$key=$val\n" };

untie %db;

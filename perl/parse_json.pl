#!/usr/bin/perl

use warnings;
use strict;
use 5.010;
use JSON::PP qw(decode_json);

my $json;

{
  local $/;
  # open my $fh, '<', 'file.json' or die $!;
  # $json = <$fh>;
  $json = <DATA>;
}

my $perl = decode_json $json;

for ( @$perl ){
  my $id = 'abc.' . $_->{ID};
  # print "$id\n";
  say "$id";
}


# Can be on one line:
# [{"mnemonic":"PT.IA1","ID":"000628"},  {"mnemonic":"EOR.1","ID":"000703"}]

__DATA__
[
{"mnemonic":"PT.IA1","ID":"000123"},
{
 "mnemonic":"EOR.1",
 "ID":"000456"
 }
]

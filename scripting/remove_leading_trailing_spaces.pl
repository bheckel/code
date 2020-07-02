#!/usr/bin/perl

$key = '  some spaces  exist  ';
$key =~ s/^\s*|\s*$//g;

print $key;
print length $key;

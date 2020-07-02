#!/usr/bin/perl

use strict;
use DBI;

my @ary = DBI->available_drivers();
print join("\n", @ary), "\n";

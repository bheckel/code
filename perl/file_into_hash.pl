#!/usr/bin/perl
##############################################################################
#     Name: file_into_hash.pl
#
#  Summary: Put a colon separated file into a hash
#
# Adapted: Mon 21 Sep 2009 13:03:24 (Bob Heckel)
##############################################################################
###use strict;
use warnings;

{ local $/ = undef; $_ = <DATA>; }

%h = /^(.*?): (.*)$/gm;

while ( (my $k, my $v) = each %h ) { print "$k=$v\n"; }

__DATA__
From: gnat@perl.com
To: camelot@oreilly.com
Date: Mon, 17 Jul 2000 09:00:00 -1000
Subject: Eye of the needle

#!/usr/bin/perl -w
##############################################################################
#     Name: client.pl
#
#  Summary: Sample client.
#
#  Adapted: Sat 10 Mar 2001 13:38:29 (Bob Heckel -- TPJ #15 Lincoln Stein)
# Modified: Fri 24 Aug 2001 11:07:15 (Bob Heckel)
##############################################################################

use strict;
###use IO::Socket::INET;
use IO::Socket;

my $s = IO::Socket::INET->new(PeerAddr => 'lisa',
                              PeerPort => 'daytime',   # port 13
                              Proto    => 'tcp',       # not required
                              Type     => SOCK_STREAM, # not required
                             );

die "Can't connect: $@" unless $s;

print $s "test";  # ignored by lisa in this case

print <$s>;                             

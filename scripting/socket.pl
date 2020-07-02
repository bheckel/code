#!/usr/bin/perl -w
##############################################################################
#     Name: socket.pl
#
#  Summary: Demo of IO::Socket.
#
#  Adapted: Mon 07 May 2001 16:59:20 (Bob Heckel www.informit.com Lincoln
#                                     Stein)
##############################################################################

use strict;

use IO::Socket;

my $server = 'mail.hotmail.com:smtp';
# Compare with my $fh = IO::Socket::File->new(); to see how similarly local
# file and network files are handled.
my $fh = IO::Socket::INET->new($server);
my $line = <$fh>;
print $line;

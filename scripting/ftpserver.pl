#!/usr/bin/perl -w

use IO::Socket::INET;
use threads;

use strict;
use Data::Dumper;

$| ++;

my $s = IO::Socket::INET->new(Proto => "tcp", LocalPort => 21, Listen => 10, Reuse => 1);
while (my $cc = $s->accept()) {
    threads->create(\&session, $cc);
    #session($cc);
}

sub session {
     my $cc = shift;
    print $cc "220 Service ready\r\n";
    my $daddr;
    my $dport;
    my $type = 'A';
    while (my $res = <$cc>) {
        $res =~ /(.*)\r\n/;
        $res = $1;
        print "<$res>\n";    
        if ($res =~ /USER (.+)/) {
            print $cc "331 user name okay, need password\r\n";
        } elsif ($res =~ /PASS (.+)/) {
            print $cc "230 User logged in\r\n";
        } elsif ($res =~ /TYPE (\w)/) {
            $type = $1;
            print $cc "200 Command okay.\r\n";
        } elsif ($res =~ /PORT (\d+),(\d+),(\d+),(\d+),(\d+),(\d+)/) {
            $dport = ($5 << 8) + $6;
            $daddr = "$1.$2.$3.$4";
            print $cc "200 Command okay.\r\n";
        } elsif ($res =~ /STOR (.+)/) {
            my $filename = $1;
            open FILE, ">", $filename;
            print $cc "150 File status okay; about to open data connection.\r\n";
            my $dc = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $daddr, PeerPort => $dport, Reuse => 1);
            if ($type eq 'I') {
                binmode($dc);
                binmode(FILE);
            } 
            my $data;
            while (read($dc, $data, 1024)) {
                syswrite(FILE, $data);
            }
            close(FILE);
            print $cc "226 Closing data connection, file transfer successful\r\n";
            close($dc);
        } elsif ($res =~ /RETR (.+)/) {
            my $filename = $1;
            if (open FILE, "<", $filename) {
                print $cc "150 File status okay; about to open data connection.\r\n";
                my $dc = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $daddr, PeerPort => $dport, Reuse => 1);
                if ($type eq 'I') {
                    binmode($dc);
                    binmode(FILE);
                }     
                my $data;
                while (read(FILE, $data, 1024)) {
                    send($dc, $data, 0);
                }
                close(FILE);
                print $cc "226 Closing data connection, file transfer successful\r\n";
                close($dc);
            } else {
                print $cc "450 Requested file action not taken. File unavailable.\r\n";
            }
        } elsif ($res =~ /QUIT/) {
            close($cc);
                        last;
        } else {
        }
    }
}

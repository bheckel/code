#!/usr/bin/perl

use DBI;
use strict;
my $DNS = shift;
my $dbh = DBI->connect($DNS);


__END__
$ /usr/share/vim/vim63/tools/pltags.pl pltags.demo.pl `perldoc -l DBI`
Then Ctl-] on the word connect to jump to that file/sub

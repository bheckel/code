#!/usr/bin/perl -w
##############################################################################
#     Name: dbi_dbd_postgresql_invest.pl (symlinked as ~/bin/invest)
#
#  Summary: Interface to the Postgresql Investments database 
#           (replaces Investments2k.mdb).
#
#           Initial data load via ~/code/misccode/invest.postgres.sql
#
#           Make sure this is running:
#           $ ipc-daemon&  <---should be a W2K Service
#
#  Created: Sun 27 Apr 2003 11:11:00 (Bob Heckel)
# Modified: Fri 23 May 2003 22:13:01 (Bob Heckel)
##############################################################################
use DBI;
use strict;
use TimeLib;  # for today's date mm/dd/yyyy

my $dbh;
my ($sth1, $sth2, $sth3, $sth4);
my @vector;
my $field;
my %h = ();
my $rc = 1;
my $more = '';  # don't use undef here

print "Starting database...\n";

$rc = system "postmaster -D $ENV{HOME}/pg/data&";
sleep 4;  # TODO wait for it instead of guessing  seconds

$dbh = DBI->connect('DBI:Pg:dbname=invest', 'bheckel', '');

if ( $dbh ) {
  # TODO loop too big
  while ( $more eq 'y' ) {
    for my $tbl ( 'funds', 'transtypes' ) {
      $sth1 = $dbh->prepare("SELECT * from $tbl");
      $sth1->execute;
      while ( @vector = $sth1->fetchrow ) {
        print "@vector\n";
      }
      $sth1->finish;
      print "\n";

      print "Enter $tbl number:  "; 
      chomp($h{$tbl} = <STDIN>);
      while ( $h{$tbl} eq '' ) {
        print "\n!!!Blanks not valid!!!\nEnter number:  "; 
        chomp($h{$tbl} = <STDIN>);
      }
    }

    print "\nEnter date (e.g. '7/7/2000') [press enter for today]: ";
    chomp($h{trandt} = <STDIN>);
    if ( $h{trandt} eq '' ) {
      $h{trandt} = shortdate();
    } else {
      # Remove commandline's mandatory quotes.
      $h{trandt} =~ s/'//g;
    }


    print "Enter price per share (e.g. 42.66): ";
    chomp($h{pricepershare} = <STDIN>);

    print "Enter number of shares (e.g. 2.25): ";
    chomp($h{shares} = <STDIN>);

    # Date types must be quoted.
    $sth2 = $dbh->prepare("INSERT INTO transacts (fundid, trandt, shares,
                                                  pricepershare, transtype) 
                          VALUES ($h{funds}, '$h{trandt}', $h{shares}, 
                                  $h{pricepershare}, $h{transtypes})");
    $sth2->execute;
    $sth2->finish;

    $sth3 = $dbh->prepare("SELECT * from transacts ORDER BY trandt DESC");
    $sth3->execute;
    while ( @vector = $sth3->fetchrow ) {
      print "@vector\n";
    }
    $sth3->finish;

=bobh
    print "Current NAV: \n";
    # Calculate the net asset value of the most recent purchase.
    $sth4 = $dbh->prepare("
              SELECT distinct (SELECT sum(shares)
                               FROM transacts
                               WHERE fundid = $h{funds}
                               GROUP BY fundid) * (SELECT distinct pricepershare
                                                   FROM transacts
                                                   WHERE fundid = $h{funds} AND trandt = (SELECT DISTINCT max(trandt)
                                                                                          FROM transacts))
              FROM transacts;
                          ");

    $sth4->execute;
    while ( @vector = $sth4->fetchrow ) {
      print "@vector\n";
    }
    $sth4->finish;
=cut

    print "more? [y/n] ";
    chomp($more = <STDIN>);
    print "DEBUG: $more\n";
  }

  $dbh->disconnect();

    my $rc2 = system "pg_ctl -D $ENV{HOME}/pg/data stop";
} else {
  print "Cannot connect to Postgres server: $DBI::errstr\n";
  print " \$dbh connection failed\n";
}

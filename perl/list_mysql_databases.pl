#!/usr/bin/perl -w
##############################################################################
#     Name: list_mysql_databases.pl
#
#  Summary: List databases in the currently running mysql daemon.
#
#  Adapted Wed 19 Jun 2002 08:14:05 (Bob Heckel -- MySQL & mSQL Randy Jay
#                                    Yarger)
##############################################################################
use DBI;

my $server = 'localhost';
# Prepare the MySQL DBD driver
my $driver = DBI->install_driver('mysql');
my @databases = $driver->func($server, '_ListDBs');
 
# If @databases is undefined we assume that the host does not have a running
# MySQL server. However, there could be other reasons for the failure. You can
# find a complete error message by checking $DBI::errmsg.
if ( not @databases ) {
  print "$server does not appear to have a running mSQL server.";
  exit(0);
}
 
foreach ( @databases ) {
  print "\nHere's a database: $_\n";
}

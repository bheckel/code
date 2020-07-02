#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql_db.indxls.pl
#
#  Summary: Load data from a file into a MySQL database.  Wipes out old 
#           table if it exists.  Used by the web IO query tool.
#
#           Take Teresa's spreadsheet, do a Save As (choose tabdelim txt), cp
#           to ~/tmp/IND.txt, uppercase it and remove first line.  Repeat for
#           OCC.txt
#
#  Created: Fri 06 Sep 2002 09:57:36 (Bob Heckel)
# Modified: Fri 15 Nov 2002 15:05:48 (Bob Heckel) 
# Modified: Fri 13 Dec 2002 10:28:43 (Bob Heckel -- determine field width
#                                     dynamically) 
##############################################################################
use strict;
use DBI();
use Load_mysql_db_util;

##################Config##########################
use constant LOADFILE => '/home/bqh0/tmp/IND.txt';
use constant DBASE    => 'indocc';
use constant TBLNAME  => 'indxls';
###use constant TBLNAME  => 'indxlsTMP';    # DEVELOPMENT
use constant DEBUG    => 0;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );
##################Config##########################

Warn(LOADFILE);

# Drop table. This may fail if TBLNAME doesn't exist.  Thus we put an
# eval around it.
eval { $dbh->do("DROP TABLE " . TBLNAME) };
print "Non-fatal error while dropping " . TBLNAME . "$@\n" if $@;

# Determine max width of input data.
open INPUTFILE, LOADFILE or die "Error: $0: $!";
my ($lenlit, $lenind, $lennaics) = 0;
while ( <INPUTFILE> ) {
  chomp $_;
  my ($lit, $ind, $naics) = split '\t';
  $lenlit = length($lit) if length($lit) > $lenlit;
  $lenind = length($ind) if length($ind) > $lenind;
  $lennaics = length($naics) if length($naics) > $lennaics;
}
# http://158.111.250.128/bqh0/cgi-bin/iocode_qry.pl?ilitbox=data+proc
print "DEBUG: max lit is $lenlit\n";
print "DEBUG: max res is $lenind\n";
print "DEBUG: max occ is $lennaics\n";
close INPUTFILE;

# Sample data:
# ABALONE BOAT^I028^I114112
# Create a new table 'foo'. This must not fail, thus we don't catch errors.
$dbh->do("CREATE TABLE " . TBLNAME . 
         " (literal VARCHAR($lenlit), 
            indnum INT($lenind) ZEROFILL, 
            naics VARCHAR($lennaics),
            INDEX idx (literal,indnum))"
        );

my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
open INPUTFILE, LOADFILE or die "Error: $0: $!";
while ( <INPUTFILE> ) {
  chomp $_;
  $sth->execute(split "\t", $_) or 
                      die "Can't execute with parameters $_: $DBI::errstr";  
  $n++;
}
close INPUTFILE;

$sth->finish();

$dbh->disconnect();

Results($n, TBLNAME, DBASE);

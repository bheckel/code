#!/usr/bin/perl -w
##############################################################################
#     Name: load_mysql_db.occxls.pl
#
#  Summary: Load data from a file into a MySQL database.  Wipes out old 
#           table if it exists.  Used by the web query tool IO query.
#
#           See load_mysql_db.indxls.pl for instructions on preparing the
#           textfile. 
#
#           Always run this and load_mysql_db.indxls.pl back-to-back.  See
#           load_mysql_db.indxls.pl for directions on re-importing. 
#
#  Created: Thu 22 Aug 2002 14:06:37 (Bob Heckel)
# Modified: Fri 15 Nov 2002 15:23:13 (Bob Heckel) 
# Modified: Fri 13 Dec 2002 10:28:43 (Bob Heckel -- determine field width
#                                     dynamically) 
##############################################################################
use strict;
use DBI();
use Load_mysql_db_util;

##################Config##########################
use constant LOADFILE => '/home/bqh0/tmp/OCC.txt';
use constant DBASE    => 'indocc';
use constant TBLNAME  => 'occxls';
###use constant TBLNAME  => 'occxlsTMP';  # DEVELOPMENT
use constant DEBUG    => 0;

my $dbh = DBI->connect("DBI:mysql:database=".DBASE.";host=localhost",
                       "bqh0", 
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );
##################Config##########################

Warn(LOADFILE);

# Drop old table. This may fail, if TBLNAME doesn't exist.  Thus we put an
# eval around it.
eval { $dbh->do("DROP TABLE " . TBLNAME) };
print "Non-fatal error while dropping " . TBLNAME . "$@\n" if $@;

# Determine max width of input data.
open INPUTFILE, LOADFILE or die "Error: $0: $!";
my ($lenlit, $lenres, $lenocc, $lensoic) = 0;
while ( <INPUTFILE> ) {
  chomp $_;
  my ($lit, $res, $occ, $soic) = split '\t';
  $lenlit = length($lit) if length($lit) > $lenlit;
  $lenres = length($res) if length($res) > $lenres;
  $lenocc = length($occ) if length($occ) > $lenocc;
  $lensoic = length($soic) if length($soic) > $lensoic;
}
print "DEBUG: max lit is $lenlit\n";
# http://158.111.250.128/bqh0/cgi-bin/iocode_qry.pl?olitbox=merchan
print "DEBUG: max res is $lenres\n";
print "DEBUG: max occ is $lenocc\n";
print "DEBUG: max soic is $lensoic\n";
close INPUTFILE;

# Sample data:
# ABALONE FISHERMAN^I#028^I610^I45-3011
# Create a new table.  This must not fail, thus we don't catch errors.
$dbh->do("CREATE TABLE " . TBLNAME . 
         " (literal VARCHAR($lenlit), 
            restriction VARCHAR($lenres), 
            occnum INT($lenocc) ZEROFILL, 
            soic VARCHAR($lensoic),
            INDEX idx (literal,occnum))"
        );

my $sth = $dbh->prepare("INSERT INTO " . TBLNAME . 
                        " VALUES (?, ?, ?, ?)"
                       ) or die "Can't prepare: $DBI::errstr";

my $n = 0;
open INPUTFILE, LOADFILE or die "Error: $0: $!";
while ( <INPUTFILE> ) {
  chomp;
  s/"//g;  # elim quotes around strings
  $sth->execute(split "\t", $_) or 
                      die "Can't execute with parameters $_: $DBI::errstr";  
  $n++;
}
close INPUTFILE;

$sth->finish();

$dbh->disconnect();

Results($n, TBLNAME, DBASE);

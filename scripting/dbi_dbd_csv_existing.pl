#!/usr/bin/perl -w
##############################################################################
#    Name: dbi_dbd_csv_existing.pl
#
# Summary: Demo of how to use DBI's DBD::CSV and SQL queries.
#          on an EXISTING csv file ("database").
#
#          Prerequisites:
#            perl -MCPAN -e 'install DBI'
#            perl -MCPAN -e 'install DBD::CSV'
#
#  Created: Fri, 26 Nov 1999 14:10:09 (Bob Heckel)
##############################################################################

use DBI;

# Access table in predefined subdirectory (subdir is the 'database').
# Don't have to specify file=.  Then you'll get all 'tables'.  Can't use e.g.
# dot.file as table name.
$dbh = DBI->connect("DBI:CSV:f_dir=//o/tmp/buildplan;" .
                    "file=Book1csv; csv_sep_char=,;")
                                  or die "Cannot connect: " . $DBI::errstr;

# Retrieve and display data from bobo.
$qry = 'SELECT * FROM Book1csv';
&queryit($qry);


# Retrieve and display data from bobo.
sub queryit {
  my $sqlqry = $_[0];

  $sth = $dbh->prepare($sqlqry);
  $sth->execute();
  while ( $row = $sth->fetchrow_hashref ) {
    print "Found: ", $row->{'PEC'}, "\n";
  }
  $sth->finish();
}


__END__
Book1csv contents:

ProdOrderNumber,PEC,QtyOrdered,CURRENTPRICE,Total,OrderStatus
RAP000001,NT4K65AB,4000,$31.0018,"$124,007.2000",Completed
RAP000002,NT3T70BD,300,$160.9952,"$48,298.5600",Active
RAP000003,NT3T84AA,250,$78.2824,"$19,570.6000",Active
RAP000004,NT3T98AA,350,"$1,031.0218","$360,857.6300",Completed
RAP000005,NT4T32BA,300,$444.1079,"$133,232.3700",Completed

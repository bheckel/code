
#!/usr/bin/perl -w

use strict;
use DBI();

# Connect to the database.
my $dbh = DBI->connect("DBI:mysql:database=test;host=localhost",
                       "bqh0",
                       "",     # MySQL pw
                       {'RaiseError' => 1}
                      );

# Drop table 'foo'. This may fail, if 'foo' doesn't exist.  Thus we put an
# eval around it.
eval { $dbh->do("DROP TABLE foo") };
print "Dropping foo failed: $@\n" if $@;

# Create a new table 'foo'. This must not fail, thus we don't
# catch errors.
$dbh->do("CREATE TABLE foo (trash INTEGER, trash2 INTEGER, trash3 INTEGER,
                            indliteral VARCHAR(50), occliteral VARCHAR(50),
                            indnum INTEGER, occnum INTEGER)");

$dbh->do("INSERT INTO foo VALUES (999, 99, 999, 
         " . $dbh->quote("DIOCESE OF PROVIDENCE") . ",
         " . $dbh->quote("MINISTER") . ", 916, 204)"
        );
$dbh->do("INSERT INTO foo VALUES (999, 99, 999,
         " . $dbh->quote("DOMINICAN FATHER") . ",
         " . $dbh->quote("CATHOLIC PRIEST") . ", 917, 205)"
        );


# Now retrieve data from the table.
my $sth = $dbh->prepare("SELECT * FROM foo");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
  print "Found a row: industry literal = $ref->{'indliteral'}, 
         industry code = $ref->{'indnum'}\n";
}
$sth->finish();

# Disconnect from the database.
$dbh->disconnect();

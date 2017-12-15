#!/usr/bin/perl -w

use DBI;

#                                 host       uid        pw
$dbh = DBI->connect('dbi:Oracle:usdev388','pks_user','pksu388')
    or die "Cannot connect: " . $DBI::errstr;

$sth = $dbh->prepare("select samp_id, matl_nbr from samp where samp_id=215694")
    or die "Cannot prepare: " . $dbh->errstr();

$sth->execute() or die "Cannot execute: " . $sth->errstr();
#                             case sensitive!
$row = $sth->fetchall_hashref('SAMP_ID');
use Data::Dumper;print Dumper $row ;

$sth->finish();       
$dbh->disconnect();



__END__
# Same as above (this is just syntactic sugar)
#                                 host       uid        pw
$dbh = DBI->connect('dbi:Oracle:usdev388','pks_user','pksu388')
    or die "Cannot connect: " . $DBI::errstr;

$sth = $dbh->prepare("select samp_id, matl_nbr from samp where samp_id=215694")
    or die "Cannot prepare: " . $dbh->errstr();

#                                    case sensitive!
$row = $dbh->selectall_hashref($sth, 'SAMP_ID');  # no execute needed
use Data::Dumper;print Dumper $row ;

$sth->finish();       
$dbh->disconnect();



#                                 host       uid        pw
$dbh = DBI->connect('dbi:Oracle:usdev388','pks_user','pksu388')
    or die "Cannot connect: " . $DBI::errstr;

$sth = $dbh->prepare("select samp_id, matl_nbr from samp where samp_id=215694")
    or die "Cannot prepare: " . $dbh->errstr();

$sth->execute() or die "Cannot execute: " . $sth->errstr();

while ( $row = $sth->fetchrow_hashref ) {
  # Case sensitive!
  print "Found: ", $row->{SAMP_ID}, " and ", $row->{MATL_NBR}, "\n";
}

$sth->finish();       
$dbh->disconnect();

#!/usr/bin/perl -w

# Spec:
# /***************************************************************************
#  NAME:    get_ae_nodes
#
#  PURPOSE: Return a cursor containing Beacon Node Content IDs that are AEs
#
#  IN:   none
#
#  OUT:  o_result_set REF CURSOR
#                     ContentID - Beacon Node Content ID
#
# ***************************************************************************/
# FUNCTION get_ae_nodes
#    RETURN cursor_type;
use DBI;
use DBD::Oracle qw(:ora_types);

my $dbh = DBI->connect('dbi:Oracle:usprd188','crcarch','temppw') or 
                                                           die $DBI::errstr;
$sth = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH.BEACON.GET_AE_NODES;
  END;
} );

$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });
$sth->execute;

while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;


######################################
# Unrelated function that accepts a parameter and returns a cursor:
use DBI;
use DBD::Oracle qw(:ora_types);

my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
my $dt = 20070501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.BEACON.get_all_contacts(:dt);
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

# The execute will automagically update the value of $sth2
$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}


######################################
# Unrelated function that returns a scalar:
use DBI;
use DBD::Oracle qw(:ora_types);

my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
$sth = $dbh->prepare( q{
  BEGIN
      :dt := CRCARCH_BATCH.WITNESS.GET_OLDEST_CONTACT;
  END;
} );

$sth->bind_param_inout(":dt", \$dt, 20);
$sth->execute;

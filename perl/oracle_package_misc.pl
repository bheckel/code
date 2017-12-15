#!/usr/bin/perl -w

use DBI;
use DBD::Oracle qw(:ora_types);

my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

$status='COMPLETED';
$oid='VENTOLIN041201093522';



$$updMedia_h = $dbh->prepare( q{
   DECLARE
      o0 VARCHAR2(32);

      FUNCTION from_bool( i BOOLEAN ) RETURN NUMBER IS
      BEGIN
         IF    i IS NULL THEN RETURN NULL;
         ELSIF i         THEN RETURN 1;
         ELSE                 RETURN 0;
         END IF;
      END;
   BEGIN
      :o0 := from_bool(CRCARCH_BATCH.ARCH.update_mestatus,:oid));
   END;

} );

$$updMedia_h->bind_param(":status", $status);
$$updMedia_h->bind_param(":oid", $oid);

$$updMedia_h->bind_param_inout(":o0", \$o0, 32);
$$updMedia_h->execute;

print $o0;

$dbh->disconnect;


__END__
my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

my $group = 'DDProdMedB';

$sth = $dbh->prepare( q{
  BEGIN
      :getGroup_h := CRCARCH_BATCH.CRCARCH.get_group_name(:group);
  END;
} );

$sth->bind_param(":group", $group);
$sth->bind_param_inout(":getGroup_h", \$getGroup_h, 255);

# The execute will automagically update the value of $sth2
$sth->execute;
###while ( my @row = $sth2->fetchrow_array ) { 
  ###print join("|",@row),"\n"; 
###}
  print $getGroup_h;

$dbh->disconnect;




my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
$sess='999999';
$reason=147;
$guid='{1234-5678}';
$fn='bob';
$ln='heckel';
$st='XX';
$d1='20070501215416';
$status='QUEUED';
$d2='20070501215416';
$ae='F';


$sth = $dbh->prepare( q{
   DECLARE
      o0 VARCHAR2(32);

      FUNCTION from_bool( i BOOLEAN ) RETURN NUMBER IS
      BEGIN
         IF    i IS NULL THEN RETURN NULL;
         ELSIF i         THEN RETURN 1;
         ELSE                 RETURN 0;
         END IF;
      END;
   BEGIN
      :o0 := from_bool(CRCARCH_BATCH.CRCARCH.ADD_LOG(:sess,:reason,:guid,:fn,:ln,:st,:d1,:status,:d2,:ae));
   END;

} );

$sth->bind_param(":sess", $sess);
$sth->bind_param(":reason", $reason);
$sth->bind_param(":guid", $guid);
$sth->bind_param(":fn", $fn);
$sth->bind_param(":ln", $ln);
$sth->bind_param(":st", $st);
$sth->bind_param(":d1", $d1);
$sth->bind_param(":status", $status);
$sth->bind_param(":d2", $d2);
$sth->bind_param(":ae", $ae);

$sth->bind_param_inout(":o0", \$o0, 32);
$sth->execute;

print $o0;

$dbh->disconnect;
      :o0 := from_bool(CRCARCH_BATCH.CRCARCH.ADD_LOG('999999',147,'1234-5678','bob','heckel','XX','20070101000000','QUEUED','20070101000000','F'));
      CRCARCH_BATCH.CRCARCH.ADD_LOG('999999',147,'1234-5678','20070101000000','QUEUED','20070101000000');
      :o0 := from_bool(CRCARCH_BATCH.CRCARCH.ADD_LOG('999999',147,'1234-5678','bob','heckel','XX','20070101000000','QUEUED','20070101000000','F'));
      :o0 := from_bool(CRCARCH_BATCH.CRCARCH.ADD_LOG('999999',147,'1234-5678','20070101000000','QUEUED','20070101000000'));



my $dbh = DBI->connect('dbi:Oracle:usprd188','crcarch','temppw') or die $DBI::errstr;

my $dt = 20070501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      CRCARCH.BEACON.get_product_contacts( :dt, :sth2 );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

# The execute will automagically update the value of $sth2
$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;





my $dbh = DBI->connect('dbi:Oracle:usprd188','crcarch','temppw') or die $DBI::errstr;

my $dt = 20070501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      CRCARCH_BATCH.BEACON.get_all_contacts( :dt, :sth2 );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

# The execute will automagically update the value of $sth2
$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;



my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

my $dt = 20070501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      CRCARCH_BATCH.BEACON.get_product_contacts( :dt, :sth2 );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;


my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
my $dt = 20070501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.BEACON.get_all_contacts( :dt  );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}
###use Data::Dumper;print Dumper $sth2->fetchrow_array ;

$dbh->disconnect;



my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
my $dt = 20060501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.CRCARCH.get_logged_sessions( :dt  );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}
###use Data::Dumper;print Dumper $sth2->fetchrow_array ;

$dbh->disconnect;



my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

my $dt = 20040319215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      CRCARCH_BATCH.BEACON.get_product_contacts( :dt, :sth2 );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;



my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
my $dt = 20070501215416;
my $sth2;

$sth = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.BEACON.get_all_contacts( :dt  );
  END;
} );

$sth->bind_param(":dt", $dt);
$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}
###use Data::Dumper;print Dumper $sth2->fetchrow_array ;

$dbh->disconnect;



my $dbhx = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf');
$sth = $dbhx->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.WITNESS.GET_ATTACHED_DATA_CONTACTS('CALLER_ROLE','FIELD%');
  END;
} );

$sth->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });
$sth->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}



my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
$sth = $dbh->prepare( q{
  BEGIN
      :dt := CRCARCH_BATCH.WITNESS.GET_OLDEST_CONTACT;
  END;
} );

$sth->bind_param_inout(":dt", \$dt, 20);
$sth->execute;

###while ( my @row = $sth2->fetchrow_array ) { 
  ###print join("|",@row),"\n"; 
###}
print $dt;

$dbh->disconnect;




my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

my $group = 'ANCEF';

$sth = $dbh->prepare( q{
  BEGIN
      :getGroup_h := CRCARCH_BATCH.CRCARCH.get_area_name(:group);
  END;
} );

$sth->bind_param(":group", $group);
$sth->bind_param_inout(":getGroup_h", \$getGroup_h, 255);

# The execute will automagically update the value of $sth2
$sth->execute;
###while ( my @row = $sth2->fetchrow_array ) { 
  ###print join("|",@row),"\n"; 
###}
  print $getGroup_h;

$dbh->disconnect;




my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
$mediaid='F';
$status='QUEUED';


$sth = $dbh->prepare( q{
   DECLARE
      o0 VARCHAR2(32);

      FUNCTION from_bool( i BOOLEAN ) RETURN NUMBER IS
      BEGIN
         IF    i IS NULL THEN RETURN NULL;
         ELSIF i         THEN RETURN 1;
         ELSE                 RETURN 0;
         END IF;
      END;
   BEGIN
      :o0 := from_bool(CRCARCH_BATCH.CRCARCH.ADD_LOG(:sess,:reason,:guid,:fn,:ln,:st,:d1,:status,:d2,:ae));
   END;

} );

$sth->bind_param(":sess", $sess);
$sth->bind_param(":reason", $reason);
$sth->bind_param(":guid", $guid);
$sth->bind_param(":fn", $fn);
$sth->bind_param(":ln", $ln);
$sth->bind_param(":st", $st);
$sth->bind_param(":d1", $d1);
$sth->bind_param(":status", $status);
$sth->bind_param(":d2", $d2);
$sth->bind_param(":ae", $ae);

$sth->bind_param_inout(":o0", \$o0, 32);
$sth->execute;

print $o0;





my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

my $group = 'DDProdMedB';

$sth = $dbh->prepare( q{
  BEGIN
      :getGroup_h := CRCARCH_BATCH.ARCH.get_group_name(:group);
  END;
} );

$sth->bind_param(":group", $group);
$sth->bind_param_inout(":getGroup_h", \$getGroup_h, 255);

$sth->execute;
  print $getGroup_h;





my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

my $vol = 'TYKERB-070531155712';
my $oid = 'TYKERB070531155712';

$sth = $dbh->prepare( q{
  BEGIN
      :num := CRCARCH_BATCH.ARCH.add_media(:vol, :oid);
  END;
} );

$sth->bind_param(":vol", $vol);
$sth->bind_param(":oid", $oid);
$sth->bind_param_inout(":num", \$num, 32);

$sth->execute;
  print $num;

$dbh->disconnect;




my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;

$sess=599998;
$reason=147;

$mediaId=197;
$status='WRITING DISC';


$sth = $dbh->prepare( q{
   DECLARE
      o0 VARCHAR2(32);

      FUNCTION from_bool( i BOOLEAN ) RETURN NUMBER IS
      BEGIN
         IF    i IS NULL THEN RETURN NULL;
         ELSIF i         THEN RETURN 1;
         ELSE                 RETURN 0;
         END IF;
      END;
   BEGIN
      :o0 := from_bool(CRCARCH_BATCH.ARCH.update_LOG(:sess,:reason,:mediaId,:status));
   END;

} );

$sth->bind_param(":sess", $sess);
$sth->bind_param(":reason", $reason);

$sth->bind_param_inout(":o0", \$o0, 32);
$sth->execute;

print $o0;

$dbh->disconnect;




my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
my $oid = 'VENTOLIN041201093522';
my $sth2;

$getCurrent_h = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.ARCH.get_media_for_order(:oid);
  END;
} );

$getCurrent_h->bind_param(":oid", $oid);
$getCurrent_h->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$getCurrent_h->execute;
while ( my @row = $sth2->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}
###use Data::Dumper;print Dumper $sth2->fetchrow_array ;

$dbh->disconnect;





my $dbh = DBI->connect('dbi:Oracle:usdev188','crcarch_mcp','app1ntf') or die $DBI::errstr;
$dbh->{FetchHashKeyName} = 'NAME_lc';
my $activeStatuses = 'REQUESTED';
my $sth2;

$getCurrent_h = $dbh->prepare( q{
  BEGIN
      :sth2 := CRCARCH_BATCH.ARCH.get_media_for_status(:activeStatuses);
  END;
} );

$getCurrent_h->bind_param(":activeStatuses", $activeStatuses);
$getCurrent_h->bind_param_inout(":sth2", \$sth2, 0, { ora_type => ORA_RSET });

$getCurrent_h->execute;
$activeRecords = $sth2->fetchall_hashref(order_id);
use Data::Dumper;print Dumper $activeRecords ;

$dbh->disconnect;

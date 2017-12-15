#!/usr/bin/perl -w

use DBI;

#                                host       uid        pw
$dbh = DBI->connect('dbi:Oracle:usprd53','crc','crc')
    or die "Cannot connect: " . $DBI::errstr;

$sql=<<END;
SELECT P.NAME, S.SESS_ID, W.WITNESS_GUID, to_char(S.START_TIME,'YYYYMMDDHH24MISS'),
       C.FIRST_NAME, C.LAST_NAME, A.STATE, NC.CONTENT_ID
FROM   SESS S, SESS_REASONS R, SESS_WITNESS W, BD_PRODUCT P, CALLER C, ADDRESS A, BD_NODE N,
       BD_NODE_CONTENT NC
WHERE  S.SESS_ID=R.SESS_ID
AND    S.SESS_ID=W.SESS_ID
AND    R.PROD_ID=P.PRODUCT_ID
AND    S.CALLER_ID=C.CALLER_ID
AND    S.CALLER_ID=A.CALLER_ID
AND    N.NODE_ID=R.NODE_ID
AND    P.NAME IS NOT NULL
AND    N.NODE_ID=NC.NODE_ID(+)
ORDER BY P.NAME, S.SESS_ID, NC.CONTENT_ID
END

$sth=$dbh->prepare($sql);
$sth->execute();

while ( my @row = $sth->fetchrow_array ) { 
  print join("|",@row),"\n"; 
}

$dbh->disconnect;

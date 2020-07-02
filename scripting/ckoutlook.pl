#!/usr/bin/perl -w
##############################################################################
#    Name: ckoutlook
#
# Summary: Check for new mail every 60 minutes sldkfjsduring business hours.
#
# Created: Wed, 20 Dec 2000 14:41:43 (Bob Heckel)
##############################################################################

use Mail::POP3Client;

$pop = new Mail::POP3Client( USER     => "bheckel",
                             PASSWORD => "lazt1One",
                             HOST     => "zrtpd00w" );
while ( 1 ) {
  $i = $pop->Count();
  $pop->Close;
  sleep(3600);
  $pop2 = new Mail::POP3Client( USER     => "bheckel",
                               PASSWORD => "lazt1One",
                               HOST     => "zrtpd00w" );
  $j = $pop2->Count();
  $pop2->Close;
  if ( $i != $j ) {
    system("/opt/msgbox Mail Time information");
  }
}

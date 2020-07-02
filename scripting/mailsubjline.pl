#!/usr/bin/perl

use Mail::POP3Client;

$pop = new Mail::POP3Client( USER     => "bheckel",
                             PASSWORD => "66Lemieux",
                             HOST     => "zrtpd00w" );


print $pop->List;
# Not sorted by time, so need to see all msgs.
for ( $i=1; $i<=$pop->Count(); $i++ ) {
  foreach ( $pop->Head($i) ) {
    print $_, "\n" if m/^Subject:/;
  }
  ###$pop->Delete($i);
}

$pop->Close;

#!/usr/bin/perl -w
##############################################################################
#     Name: cookie_time.pl
#
#  Summary:  Convert timeval to RFC822 format (Zulu time zone, aka GMT, UTC, 
#            etc.)  The dashes in the date string are not specified by RFC822,
#            but they seem to be a popular perversion of the standard.
#
# Adapted: Fri 30 Nov 2001 13:21:48 (Bob Heckel -- Mark Hewett's TimeLib.pm)
##############################################################################

@WEEKDAYS = ('Sunday','Monday','Tuesday','Wednesday', 'Thursday','Friday',
                                                                  'Saturday');
@MONTHS = ('January','February','March','April','May','June', 'July',
                        'August','September','October','November','December');

# E.g. tommorow.
print cvtimeHTTP(time + 86400);


sub cvtimeHTTP {
  my($t) = @_;

  $t = $t || time;

  # Must be in GMT for cookie to function properly.
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($t);

  printf ("%s, %02d-%3s-%4d %02d:%02d:%02d GMT",
                                          $WEEKDAYS[$wday],
                                          $mday, $MONTHS[$mon], $year+1900,
                                          $hour,$min,$sec);
}

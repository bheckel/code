#!/usr/bin/perl
##############################################################################
#     Name: kids.pl
#
#  Summary: Check user's input for a familiar email address then display
#           website.
#
#  Created: Fri, 23 Jun 2000 16:47:48 (Bob Heckel)
##############################################################################
###unshift (@INC, '/export/home/bheckel/html/');
require eandb_html;

$DEBUG = 1;
###$i = 0;

# Disable this when in production:
use CGI::Carp qw(fatalsToBrowser set_message);
BEGIN {
  sub handle_errors {
    my $msg = shift;
    print "<h1>Don't Panic.</h1>";
    print "Error: $msg <BR>";
  }
  set_message(\&handle_errors);
}

# <><><><><><><><><><><> Begin Standard Header <><><><><><><><><><><><><><><><
# Get form data via GET or POST methods.
if ( $ENV{'QUERY_STRING'} eq "" ) {
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
} else { 
  $buffer = $ENV{'QUERY_STRING'};
}

# Split the name-value pairs.
@pairs = split(/&/, $buffer);
foreach $pair ( @pairs ) {
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $Form{$name} = $value;
}

if ( $ENV{HTTP_COOKIE} ) {
  # Tail -f /apache/logs/error_log to view.
  warn "DEBUG>HTTP_COOKIE: $ENV{HTTP_COOKIE}<DEBUG" if $DEBUG;
  @cpairs = split(/;/, $ENV{HTTP_COOKIE});
  foreach $cpair ( @cpairs ) {
    ($cookiename, $cookieval) = split(/=/, $cpair);
    # De-webify plus signs and %-encoding
    $cookieval =~ tr/+/ /;
    $cookieval =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    # Stop people from using subshells to execute commands
    $cookieval =~ s/~!/ ~!/g;
    warn "DEBUG>Cookie guts: $cookiename = $cookieval<DEBUG" if $DEBUG;
  }
}
#<><><><><><><><><><><><> End Standard Header <><><><><><><><><><><><><><><><>

# Check for previous authorization.
if ( $cookieval eq 'blade_runner' ) {
  # User is looking for the archive page by clicking button on main page.
  if ( $Form{archivesubmit} ) {
    render_page('want_archivepg');
  } else {
    # Been here in the last month, wants main page.
    render_page('returning_user');
  }
}

# Never been here before or cookie has expired.
if ( $cookieval ne 'blade_runner' ) {
  warn "DEBUG> no cookie, right?: $cookieval <DEBUG";
  # Present welcome then auth on Submit.
  authorize_user($Form{emailaddr});
}



sub authorize_user {
  my $users_addr = shift;

  $ok = 0;  # initialize

  # User didn't type any email address.
  if ( $users_addr eq '' ) {
    render_page('first_time');
    exit;
  } else {
    warn "DEBUG>!!! $users_addr !!! $Form{emailaddr} !!!<DEBUG" if $DEBUG;
    # Keep going, some string was passed in from user.
  }

  ###open(PASSWD, $PASSWD) || die "Can't open $PASSWD: $!\n";
  ###@the_addrs = <PASSWD>;
  ###close(PASSWD);
  ###$ok = grep /$users_addr/, @the_addrs;
  $eandb_html::allowed_users =~ tr/a-zA-Z/n-za-mN-ZA-M/;
  $ok = grep /$users_addr/, $eandb_html::allowed_users;
  if ( $ok ) {
    # Authorized, finished checking.
    render_page('just_authed');
    exit;
  } else {
    print "Content-type: text/html\n\n";
    print "The email address <B>$Form{emailaddr}</B> is not in my database.";
    print "  Sorry.  Please click Back to try again.";
    exit;
  }
}


# Display HTML from eandb_html.pm
sub render_page {
  my $experience = shift;
  warn "DEBUG> experience: $experience <DEBUG" if $DEBUG;

  #                              days seconds/day
  $cookie_expire = cvtimeHTTP(time+90*86400);
  warn "DEBUG> cookiedeath: $cookie_expire <DEBUG" if $DEBUG;

  if ( $experience eq 'first_time' ) {
    print "Content-type: text/html\n\n";
    print $eandb_html::welcome;
    exit;
  } elsif ( $experience eq 'just_authed' ) {
    ###print "Set-Cookie: USER=blade_runner; path=/; expires=Friday, 30-Nov-01 23:12:40 GMT\n";
    print "Set-Cookie: USER=blade_runner; path=/; expires=$cookie_expire\n";
    print "Content-type: text/html\n\n";
    print $eandb_html::mainpage;
  } elsif ( $experience eq 'want_archivepg' ) {
    print "Content-type: text/html\n\n";
    print $eandb_html::archivepage;
  } elsif ( $experience eq 'returning_user' ) {
    print "Content-type: text/html\n\n";
    print $eandb_html::mainpage;
  } else {
    # Error.
    warn "DEBUG> experience unknown: $experience <DEBUG" if $DEBUG;
  }
}


# Build RFC822 compliant date string for cookie.
sub cvtimeHTTP {
  my($t) = @_;
  
  @weekdays = ('Sunday','Monday','Tuesday','Wednesday', 'Thursday','Friday',
                                                                  'Saturday');
  @months = ('January','February','March','April','May','June', 'July',
                        'August','September','October','November','December');
  $t = $t || time;
  
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($t);
  
  sprintf ("%s, %02d-%3s-%4d %02d:%02d:%02d GMT",
                                          $weekdays[$wday],
                                          $mday, $months[$mon], $year+1900,
                                          $hour,$min,$sec);
}

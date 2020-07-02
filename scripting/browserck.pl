#!/usr/bin/perl -w
##############################################################################
#     Name: browserck.pl
#
#  Summary: Immediately go to page based on client's browser.
#           Symlink ln -s ~/code/perl/browserck.pl ~/html/cgi-bin/browserck.pl
#           then call via 
#           http://localhost/cgi-bin/browserck.pl
#
#  Adapted: Thu 14 Jun 2001 13:41:33 (Bob Heckel -- InformIT CGI in a Week)
##############################################################################

@user_agent = split(/\//, $ENV{'HTTP_USER_AGENT'});

if ( $user_agent[0] eq "Mozilla" ) {
  @version = split(/ /,$user_agent[1]);
  $version_number = substr($version[0], 0, 3);
  if ( $version_number < 1.1 ) {
    print "Location: http://47.143.212.20\n\n";
  }
  else{
    print "Location: http://47.143.212.30\n\n";
  }
} else {
  print "Location: http://47.143.212.40\n\n";
}

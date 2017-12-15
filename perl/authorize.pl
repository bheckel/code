#!/usr/bin/perl
##############################################################################
#     Name: authorize.pl
#
#  Summary: Check user's input for user id and password and kickoff an upload
#           menu if successfully authenticated.
#
#           The name authorize.pl is slightly misleading since it generates an
#           HTML input area when finished authenticating.
#
#           TODO separate HTML from code.
#
#  Created: Fri, 23 Jun 2000 16:47:48 (Bob Heckel)
# Modified: Tue, 14 Nov 2000 16:00:10 (Bob Heckel)
##############################################################################

#...
$DEBUG = 0;

use CGI::Carp qw(fatalsToBrowser set_message);
BEGIN {
  sub handle_errors {
    my $msg = shift;
    print "<h1>Don't Panic.</h1>";
    print "Omigosh: $msg<BR>";
  }
  set_message(\&handle_errors);
}
#...

# Which database to verify pw.
$PASSWD = '/opt/grsuite/etc/passwd';
$FOOTER = '<CENTER><HR SIZE=1><SMALL><I>&copy;2000 Solectron Corporation, ' .
          'RTP<BR>Information Technology Group<BR></I></SMALL></CENTER>';

# ----------------------- Begin Standard Header ------------------------------
# Print out a content-type for HTTP/1.0 compatibility
print "Content-type: text/html\n\n";
# Print a title and initial heading
print <<EOT;
<HTML><HEAD><TITLE>GenRad Cadfile Uploader</TITLE></HEAD>
<BODY><TABLE>
<TR><TD><IMG SRC='http://47.143.210.230/~bheckel/cboard.gif' BORDER='0'></TD>
<TD VALIGN='bottom'><H2>GenRad Cadfile Uploader</H2></TD>
</TR></TABLE><HR>
EOT

# Get form data via GET or POST methods
if ( $ENV{'QUERY_STRING'} eq "" ) {
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
} else { 
  $buffer = $ENV{'QUERY_STRING'};
}

# Split the name-value pairs
@pairs = split(/&/, $buffer);
foreach $pair ( @pairs ) {
  ($name, $value) = split(/=/, $pair);
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
  $Form{$name} = $value;
}

if ( $ENV{HTTP_COOKIE} ) {
  @cpairs = split(/;/, $ENV{HTTP_COOKIE});
  foreach $cpair ( @cpairs ) {
    # Don't look at the other apps (Webcad/cadfile) cookies holding PEC code.
    next if $cpair =~ /c_rshcadmru/;
    ($cookiename, $cookieval) = split(/=/, $cpair);
    # Un-Webify plus signs and %-encoding
    $cookieval =~ tr/+/ /;
    $cookieval =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    # Stop people from using subshells to execute commands
    $cookieval =~ s/~!/ ~!/g;
  print "Cookie guts: $cookiename = $cookieval<BR>" if $DEBUG;
  }
}
# ------------------------ End Standard Header ----------------------------

# Check for previous authorization or file name submitted.
if ( $ok == 1 ) {
  # User has been authenticated.
  uploaderpage($ok);
} else {
  # First pass at form, check identity.
  getuser($Form{pwck_name}, $Form{pwck_pw});
}


sub getuser {
  my $forminput_name = $_[0];
  my $forminput_pw   = $_[1];
  # If user previously authenticated, skip repeat auth.
  $ENV{REMOTE_USER} || getshadow($forminput_name, $forminput_pw);
}


sub getshadow {
  my $forminput_name = $_[0];
  my $forminput_pw   = $_[1];

  unless ( $Form{pwck_name} ) { print 'User not found in database.' };
  open(SHADOW, $PASSWD) || die "Can't open $PASSWD: $!\n";
  while ( <SHADOW> ) {
    chop;
    #                 ---------future use-------------
    ($userid, $encrypw, $uid, $gid, $gcos, $home, $shell) = split(/:/);
    if ( $userid eq $forminput_name ) {
      cryptcheck($userid, $forminput_pw, $encrypw);
      last;
    }
  }
  close(SHADOW);
  print "User $forminput_name is not in database.  Sorry.";
  print "  Please click Back to try again.";
  exit;
}


sub cryptcheck {
  my $userid       = $_[0];
  my $forminput_pw = $_[1];
  my $encrypw      = $_[2];

  if ( crypt($forminput_pw, $encrypw) ne $encrypw ) {
    print "Authorization failed.  Sorry, password does not match the " .
          "user $userid password.<BR>";
    print "<BR>Please go <A HREF=javascript:history.go(-1)>Back</A> " .
          "to try again.<BR><BR>$FOOTER";
    exit;
  } else {
    # Success.
    $ok = 1;
    $ENV{REMOTE_USER} = $forminput_name;
    # Authorized, finished checking.
    uploaderpage();
    exit;    
  }
}


# Real path w/o ScriptAlias:
# <FORM ACTION="http://47.143.210.230/cgi-bin/bheckel/uploader.pl" METHOD="POST" NAME="myform2" ENCTYPE="multipart/form-data">
sub uploaderpage {
  # First time user without cookie should see /gr8xprog/ instead of a blank
  # textbox.
  unless ( $cookieval ) { $cookieval='/gr8xprog/' };
  print <<"EOT";
<HTML><BODY>
<H3>Upload your local copy of file:</H3>
<FORM ACTION="http://47.143.210.230/Webcad/uploader" METHOD="POST"
 NAME="myform2" ENCTYPE="multipart/form-data">
  <INPUT TYPE="file" NAME="filename_fromPC" SIZE="50"><BR><BR><BR><BR>
  <H3>To this location <EM> and name </EM> on the GenRad Server:<BR>
  Example: /gr8xprog/lx72aa/cad/lx7202_08.cad<BR>
  Where lx72aa is the pec code and lx7202_08.cad is the board artwork &amp;
  release with a .cad extension.<BR><BR>Please make sure a 'cad' 
  subdirectory is part of the upload path.<BR>  
  Warning: Existing .cad files <EM>will be silently overwritten</EM></H3>
  <INPUT TYPE="text" NAME="path_on_gr" VALUE="$cookieval" SIZE="50">
  <INPUT TYPE="submit" NAME="uploadbutton" VALUE="Upload File">
  <INPUT TYPE="submit" NAME="deletebutton" VALUE="Delete File">
</FORM>$FOOTER</BODY></HTML>
EOT
}

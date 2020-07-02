#!/usr/bin/perl -w
##############################################################################
#     Name: uploader.pl
#
#  Summary: Given a file from the machine a browser is running on,
#           upload it to specified path on the Solaris Genrad server.
#           Allows single file deletions via radio buttons or textbox.
#
#           Must be run via a setuid wrapper since it must write only as
#           gr8xprog, not httpd. 
#
#  Created: Fri, 21 Jul 2000 10:42:19 (Bob Heckel)
# Modified: Tue, 21 Nov 2000 09:39:17 (Bob Heckel)
##############################################################################

#...
use CGI::Carp qw(fatalsToBrowser set_message);
BEGIN {
  sub handle_errors {
    my $msg = shift;
    print "<h1>Don't Panic.</h1>";
    print "Omigosh: $msg<BR>";
  }
  set_message(\&handle_errors);
}

my $DEBUG = 0;
#...

use strict;
# Used for upload(), param() and successful_upload().
use CGI qw(:standard);

#--------------------------------------------------------------
# Globals.
my $GIF    = 'http://47.143.210.230/~bheckel/cboard.gif';
my $MYSELF = 'http://47.143.210.230/Webcad/uploader';

my $HDR =<< "EOT";
</PRE><TITLE>GenRad Cadfile Uploader</TITLE><TABLE><TR><TD>
<IMG SRC=$GIF BORDER=0></TD> <TD VALIGN='bottom'>
<H2>GenRad Cadfile Uploader</H2></TD></TR></TABLE><HR>
EOT

my $FOOTER =<< 'EOT';
<CENTER><HR SIZE=1><SMALL><I>&copy;2000 Solectron
Corporation, RTP<BR>Information Technology Group
<BR></I></SMALL></CENTER>
EOT
#--------------------------------------------------------------

# Navigation.
my $historygoback = undef;

# First, make sure this isn't a delete request from a previous run.
if ( defined(param('delradiosel')) ) {
  my $unlinkme = param('delradiosel');
  my $frontpath = param('hiddenpath');
  my $full = $frontpath . $unlinkme;
  ru_shure($full) unless defined(param('beenthereonce'));
  ###defined(param('beenthereonce')) ? $historygoback = 1 : $historygoback = 3;
  ###deleter($unlinkme, $frontpath, $historygoback);
}
# Then check if user clicked the delete button to remove a specific file in
# the adjacent textbox.
elsif ( defined(param('deletebutton')) ) {
  my $grpath = param('path_on_gr');
  # Break up fully qualified path to delete file.
  $grpath =~ m|(.*[/\\:])+([^/\\:]+)$|;
  my $path = $1;
  my $file = $2;
  warn "DEBUG>path: $path<DEBUG\n";
  warn "DEBUG>file: $file<DEBUG\n";
  # Delete specfic file in param('path_on_gr')
  ru_shure($grpath) unless defined(param('beenthereonce'));
  untaint($file);
  defined(param('beenthereonce')) ? $historygoback = 1 : $historygoback = 2;
  deleter($file, $path, $historygoback);
}
else {
  # The most common event is to upload.
  normalupload();
}


sub normalupload {
  # Bytes read from file uploaded as specified by textbox.
  my $bytesread = 0;
  # The filename returned by upload() is also a filehandle.
  my $filehandle = upload('filename_fromPC');
  # Where user wants his path/file uploaded.
  my $savelocation = param('path_on_gr');

  warn "DEBUG>savelocation is: $savelocation<DEBUG" if $DEBUG;
  print "Set-cookie: uploadpath=$savelocation; expires=" . cookiedate() . "\n";
  print header, '<HTML><BODY><PRE>';
  my $cleansaveloc = untaint($savelocation);
  # If needed, mkdir the new path.
  my $newdircreated = "";
  $newdircreated = mknewdir($cleansaveloc, $filehandle, $bytesread);
  # Initialize.  Location requested is writeable by httpd.
  my $success = 0;
  # File must be uploaded to a location writeable by gr8xprog.
  if ( open(SAVE, ">$cleansaveloc") ) {
    if ( $filehandle ) {
      undef my $bytes;
      undef my $buffer;
      while ( $bytes = read($filehandle, $buffer, 1024) ) {
        $bytesread += $bytes;
        print SAVE $buffer;
      }
      $bytesread = commafy($bytesread);
      close($filehandle); 
      close(SAVE);
      $success = 1;
    }
    if ( $success ) {
      successful_upload($filehandle, $bytesread, $savelocation, $newdircreated);
    } else {
      failed_upload($filehandle, $bytesread);
      warn "DEBUG>failed_upload 1 $filehandle<DEBUG\n";
    }
  } else {
    # Illegal save location -- failed upload.
    failed_upload($filehandle, $bytesread);
    warn "DEBUG>failed_upload 2 $filehandle<DEBUG\n";
  }
}

# Eliminate "Insecure dependency in open while running setuid at uploader.pl
# line 28" tainting errors.
sub untaint {
  my $string = $_[0];

  # Only allow .cad files to upload.
  if ( $string =~ /(.*\.cad)$/ ) {
    $string = $1;     # $string now untainted.
    return $string;
  } else {
    # Log this to Apache's error_log to track cracking attempts.
    warn "DEBUG>Tainted data in $string<DEBUG";
  }
}


# User may want to add a cad file to a new peccode so need to mkdir /cad if it
# doesn't already exist.
sub mknewdir {
  my $cleansaveloc_in  = $_[0];
  my $filehandle_in    = $_[1];
  my $bytesread_in     = $_[2];

  my ($dir, $file) = $cleansaveloc_in =~ m!(.*/)(.*)!s;

  # Only allow upload to a cad dir.
  unless ( $dir =~ /\/cad/ ) { 
    warn "DEBUG>disallowed upload: $filehandle_in to $cleansaveloc_in<DEBUG\n";
    disallowed_upload($filehandle_in, $bytesread_in);
    # Silently exits.
  }

  # Prints this blank to the browser if no new dir needed to be created.
  my $newdir_created = "";

  if ( !-d $dir ) {
    my $longerpath = "";
    my $sofar      = "";

    my @pathpieces = split(/\//, $dir);

    # Build path incrementally.
    foreach my $piece ( @pathpieces ) {
      next if $piece eq "";
      my $sofar = $longerpath . '/' . $piece . '/';
      # User's umask can make this more restrictive.
      # If dir already exists, just keep going, no errortrap.
      mkdir($sofar, 0777);
      $longerpath = $sofar;
      $sofar = "";
    }
    $newdir_created = "A new subdirectory was created as a result of this " .
                      "upload.";
  }
  return $newdir_created;
}


sub cookiedate {
  # E.g. Sat Dec 29 22:11:04 GMT 2001
  my @weekdays = ('Sun','Mon','Tues','Wed', 'Thur','Fri', 'Sat');
  my @months   = ('Jan','Feb','Mar','Apr','May','Jun', 'Jul', 'Aug','Sep',
                  'Oct','Nov','Dec');
  # 100days x 24hrs x 60min x 60sec = 8,640,000.
  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
                                                     gmtime(time() + 8640000);
  my $expdate = sprintf ("%s, %02d %3s %4d %02d:%02d:%02d GMT",
                         $weekdays[$wday], $mday, $months[$mon], $year+1900, 
                         $hour, $min, $sec);
  warn "DEBUG>Cookie expires: $expdate<DEBUG\n" if $DEBUG;

  return $expdate;
}


# Insert commas separating the thousands.
###sub commafy {
###  my ($number) = $_[0];
###  my @result;
###
###  while ( $number ) {
###    push @result, ($number % 1000) , ',';
###    ###$number = int($number / 1000);
###    $number = int($number / 1000);
###  }
###  pop @result;      # Remove trailing comma
###  return reverse @result;
###}
sub commafy {
  local $_  = shift;
  1 while s/^([-+]?\d+)(\d{3})/$1,$2/;
  return $_;
}



# TODO more HTML to separate templates.


sub deleter {
  my $unlinkme_in  = $_[0];
  my $frontpath_in = $_[1];
  # How many pages to go back.  Need 2 if skipping "expired" page.
  my $goback       = $_[2];

  # Prepend fully qualified path.
  $unlinkme_in = $frontpath_in . $unlinkme_in;
  # If it is defined, do it and get out before the normal 'cad' taint checking
  # begins.
  if ( defined($unlinkme_in) ) {
    my $cleandel = untaint($unlinkme_in);
    my $deleted = undef;
    $deleted = unlink($cleandel) or $deleted = 0;
    print header, $HDR;
    if ( $deleted ) {
      print <<"EOT";
<BR><CENTER><FONT COLOR="green">
$cleandel has been successfully deleted from the grserver<BR><BR></FONT>
<A HREF=javascript:history.go(-$goback)>Back</A></CENTER>
$FOOTER
EOT
      exit 0;
    } else {
      print <<"EOT";
<CENTER><BR><FONT COLOR="red">Unable to delete $unlinkme_in: $!.</FONT>
<BR><BR><A HREF=javascript:history.go(-$goback)>Home</A></CENTER>
<BR>
$FOOTER
EOT
    }
  }
}


sub successful_upload {
  my $filehandle_in    = $_[0];
  my $bytesread_in     = $_[1];
  my $savelocation_in  = $_[2];
  # Empty if no dir was created.
  my $newdircreated_in = $_[3];

  # Prepare delete menu.
  # Strip off directory.
  $savelocation_in =~ m|(.*[/\\:])+[^/\\:]+$|;
  opendir(DIRHANDLE, $1) || warn "$0--Can't open dir: $!\n";
  # Filter out dotfiles.
  my @files = grep(!/^..?$/, readdir(DIRHANDLE));
  foreach my $file ( @files ) {
    $file = "<INPUT TYPE=RADIO NAME=delradiosel VALUE=$file>$file";
  }
  closedir(DIRHANDLE);

  print <<"EOT";
$HDR
<H3>Your file <FONT COLOR='green'>$filehandle_in ($bytesread_in bytes)</FONT>
<BR>has been successfully uploaded as
<BR>
<FONT COLOR='green'>$savelocation_in</FONT> on the GenRad Server</H3>
<BR>$newdircreated_in
<FORM NAME='delfile' ACTION=$MYSELF><CENTER>
<B>CAD files on grserver:</B> @files
<BR>
<BR>
<INPUT TYPE='hidden' NAME='hiddenpath' VALUE=$1>
<INPUT TYPE='submit' VALUE='Delete File On grserver'>
</FORM>
<BR>
<BR>
<A HREF=javascript:history.go(-1)>Home</A>
</CENTER>
$FOOTER
</BODY></HTML>
EOT
}


sub failed_upload {
  my $filehandle_in   = $_[0];
  my $bytesread_in    = $_[1];
  my $savelocation_in = $_[2];

  $filehandle_in = '&lt;missing&gt;' unless defined($filehandle_in);

  print <<"EOT";
$HDR
<H3>Your file <FONT COLOR='green'>$filehandle_in ($bytesread_in bytes)</FONT>
<BR>has <EM><FONT COLOR='red'>not</FONT></EM> been uploaded as
<BR>
<FONT COLOR='green'>$savelocation_in</FONT> on the GenRad Server
<BR>
<BR>
This often indicates a bad input file from your machine</H3>
<BR><CENTER>
<A HREF=javascript:history.go(-1)>Back</A>
</CENTER>
$FOOTER
</BODY></HTML>
EOT
}


# Does not return.
sub disallowed_upload {
  my $filehandle_in = $_[0];
  my $bytesread_in  = $_[1];

# TODO put header, <HTML... in $HDR
  print <<"EOT";
$HDR
<H3>Sorry, your file <FONT COLOR='green'>$filehandle_in ($bytesread_in bytes)
</FONT>
<BR>was <EM><FONT COLOR='red'>not</FONT></EM> uploaded.
<BR>
<BR>Please be sure to upload .cad file to a subdirectory specifically 
named 'cad'.<BR>E.g. /gr8xprog/lx72aa/cad</H3>
<BR><CENTER>
<A HREF=javascript:history.go(-1)>Back</A>
</CENTER>
$FOOTER
</BODY></HTML>
EOT
  # Die quietly.
  exit 0;
}


# Confirmation screen for deletes.
sub ru_shure {
  my $file_in = $_[0];

  print header;
  print <<"EOT";
$HDR
Are you sure?
<TABLE><TR>
<TD><FORM ACTION="http://47.143.210.230/Webcad/uploader" METHOD="POST"
     ENCTYPE="multipart/form-data">
    <INPUT TYPE="submit" NAME="deletebutton" VALUE="Delete File $file_in">
    <INPUT TYPE="hidden" NAME="beenthereonce">
    <INPUT TYPE="hidden" NAME="path_on_gr" VALUE=$file_in>
</FORM>
<TD><FORM><INPUT TYPE="submit" VALUE="Do Not Delete" onClick="history.go(-1)">
</FORM></TR></TABLE>
$FOOTER
EOT
  # Die quietly.
  exit 0;
}

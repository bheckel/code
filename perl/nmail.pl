#!/usr/bin/perl -w
##############################################################################
# Program Name:  nmail
#
#      Summary:  Generates an email template reply in NetMail95-ready format.
#                Creates new message template if no ARGV is passed to it.
#                TODO handle cc: and forwards.
#
#      Created:  Tue Feb 16 1999 14:22:56 (Bob Heckel)
#     Modified:  Thu Feb 18 1999 21:25:38 (Bob Heckel--bug fixes)
#     Modified:  Tue Mar 23 1999 21:07:41 (Bob Heckel--use my pm, add usage
#                                          help)
#     Modified: Fri, 27 Aug 1999 20:10:56 (Bob Heckel--improve .txt reply with
#                                          > quotes, modi local_date_time.pm)
##############################################################################

$whoami = 'rsh@technologist.com';
$realname = 'Bob Heckel <rsh@technologist.com>';
$smtpout = '/util/nm95/smtpout/';  
# Not used by Netmail95 but technically correct to use.
$mailserver = 'mail.mindspring.com';  

# I created this for learning, not efficiency.
use BobHTime::local_date_time;

# Replying to an existing message if filename was passed to nmail.
if ((@ARGV) && ($ARGV[0] ne '--help')) {
  # Want current not-yet-replied-to email's filename & extension only.
  $meshort = &getbasenm($ARGV[0]);
  &quotetext;
  open(FIL, "$ARGV[0]") || die ("Can't open file $ARGV[0] !\n");
  while(<FIL>) {
    # Full English email address.  E.g. From: Robert Heckel <bheckel@nt.com>
    # TODO Change regex for unusual email addressed e.g. redherr@one.two.com
    if (s/(^From: +.*?<?\w+@\w+(.\w+)*>?)/$1/) {
      $emailaddrfrm = $1;
      # Elim the From: for status message displayed during runtime.
      $emailaddrnofrm = substr($1, 6);
      print "\nReplying to:  $emailaddrnofrm with files $smtpout$meshort.txt and .wrk\n";
    }
    if (/^Subject: +(.*)/) {
      # TODO avoid messy Re: RE: re: lines potential.
      print "\nSubject is:  Re: $1\n\n";
      $subj = $1;
      # Without this, can get multiple replies if the replying email has a
      # From: line in the quoted '>' area.
      last;
    }
  }
  close(FIL);
  &makewrk($emailaddrnofrm, $meshort, $smtpout);
  &maketxt($emailaddrfrm, $meshort, $smtpout, $subj);
} 
elsif ((@ARGV) && $ARGV[0] eq '--help') {
  print "Usage: nmail [replyingtothisemail]\n";
} 
# Create a new txt and wrk; not replying.
# TODO allow commandline switch passing email address to populate To: and .wrk
# last line.
else {
  # Time used for unique name.
  $newname = $smtpout . time();
  $newmail = $newname . ".txt";
  $newmailwrk = $newname . ".wrk";
  &makenewwrktxt($newmail, $newmailwrk);
  print "\nNew email created using filenames $newmail and .wrk\n\n";
}

# Create replying wrk file.
sub makewrk {
  ###my @in = @_;
  ###my $replyto = $in[0];
  ###my $meshortin = $in[1];
  ###my $smtpout = $in[2];
  my ($replyto, $meshortin, $smtpout) = @_;
  # Reply files in dir that nm95 expects them to be in.
  # Must elim the .wrk to prevent out.txt.wrk
  $meshortin =~ s/\....//;
  $openme = $smtpout . $meshortin . '.wrk';
  open(WRK, ">$openme") || die ("Can't open file $openme!\n");
  # From me.  Required twice for NetMail's historical mail protocol purposes.
  print WRK ("$mailserver\n");
  print WRK ("$whoami\n");
  # Must elim the From: "Robert Heckel" preceding the
  # <bheckel@nortelnetworks.com>  REMOVED ABOVE...right??
  $replyto =~ s/>$//;
  $replyto =~ s/^.*?<//;
  print WRK ("$replyto\n");
  close(WRK);
}

# Create replying txt file.
sub maketxt {
  ###my @in = @_;
  ###my $replyto = $in[0];
  ###my $meshortin = $in[1];
  ###my $smtpout = $in[2];
  ###my $subjin = $in[3];
  my($replyto, $meshortin, $smtpout, $subjin) = @_;
  # Must elim the .txt to prevent out.txt.txt
  $meshortin =~ s/\....//;
  $openme = $smtpout . $meshortin . '.txt';
  $TXT = $smtpout;
  open(TXT, ">$openme") || die ("Can't open file $openme!\n");
  print TXT ('From: ' . "$realname\n");
  $replyto =~ s/From:/To:/;
  print TXT ("$replyto\n");
  print TXT ("Subject: Re: $subjin\n");
  # Returns e.g. Wed, 17 Feb 1999 16:50:06 -0500 (EST)
  $daat = &local_date_time;
  print TXT "Date: $daat\n\n\n";
  print TXT "Original message:\n";
  # TODO control the scope of this -- @wholeorigin is the  >  modi version.
  print TXT @wholeorig;
  close(TXT);
}

# Not replying so simply create new email txt & wrk file.
sub makenewwrktxt {
  ###my $in = $_[0];
  ###my $in2 = $_[1];
  my($in, $in2) = @_;
  open(NEWTXT, ">$in") || die ("Can't open file $in !\n");
  print NEWTXT ('From: ' . "$realname\n");
  print NEWTXT ("To:\n");
  print NEWTXT ("Subject: \n");
  # Want Wed, 17 Feb 1999 16:50:06 -0500 EST
  $daat = &local_date_time;
  print NEWTXT "Date: $daat\n\n\n";
  close(NEWTXT);
  open(NEWWRK, ">$in2") || die ("Can't open file $in2 !\n");
  # From me.
  print NEWWRK ("$mailserver\n");
  print NEWWRK ("$whoami\n");
  # TODO how to get this automatically from txt ??
  print NEWWRK ("...need a To:  address here ...");
  close(NEWWRK);
}

# Capture the lowest dir from the passed fully qualified path.
# TODO use Perl module to do this.
sub getbasenm {
  my $in = $_[0];
  # Clean up the path to not confuse following code with the trailing / 
  $in =~ s/\/$//g;
  # Capture position number of char preceeding / then add one to land on the
  # slash specifically.  This is where substr will start extracting to the
  # end.
  $position = rindex($in, "/") + 1;
  $basenm = substr($in, $position);
  # Space-in-path names may have trailing  "  to be removed if w95.
  $basenm =~ s/\"$//;
  return $basenm;
}

# Insert entire original email sent to you with leading  >  
# TODO elim header trash with regex.
sub quotetext {
  open(FIL, "$ARGV[0]") || die ("Can't open file $ARGV[0] !\n");
  @wholeorig = <FIL>;
  close(FIL);
  foreach $line (@wholeorig) {
    $line =~ s/^/>/;
  }
}


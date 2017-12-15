#!/usr/bin/perl
##############################################################################
#     Name: mail.pl
#
#  Summary: Send outgoing mail, if any.
#           Fetch header/body of email from POP3 server.
#           Compose new or reply to existing email. if any.
#
#           This program is free software; you can redistribute it and/or
#           modify it under the terms of the GNU General Public License
#           as published by the Free Software Foundation; either version 2
#           of the License, or (at your option) any later version.
#     
#           Copyright 2000. Robert S. Heckel Jr.
#           This program is distributed in the hope that it will be useful,
#           but WITHOUT ANY WARRANTY; without even the implied warranty of
#           MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#           GNU General Public License for more details.
#
#           TODO implement Win32 dialing.
#           TODO better error handling.
#           TODO Skip viewing headers from Return-Path: to Date:
#           TODO view mailserver's chatter on sending
#
#  Created: Sun, 16 Jul 2000 21:06:27 (Bob Heckel)
# Modified: Sun 01 Apr 2001 10:47:50 (Bob Heckel)
##############################################################################

# TODO 
###use strict;
use warnings;
use Mail::POP3Client;
use Getopt::Std;
use Net::SMTP;
# Checks for To: lines not addressed to me (or from known, non-spam addresses).
# TODO improve, OO design.
require Spamfilter;
require Local_date_time;

use constant DEBUG => 0;
my $VERSION      = '2.1';
my $XMAIL        = 'HeckelMail v2.1';
my $senders_addr = 'rsh@technologist.com';
my $incoming_dir = '/home/bheckel/smtpin';
my $outgoing_dir = '/home/bheckel/smtpout';
my $sent_dir     = '/home/bheckel/smtpsent';
my $lettersuffix = 'mail';
my $mailserver   = 'mail.mindspring.com';
my $userid       = 'bheckel';
my $full_from    = 'Bob Heckel <rsh@technologist.com>';
# TODO .netrc or something this.
my $pw           = '';
my $replytome    = $ARGV[1];

#    Help   New     Reply.
our($opt_h, $opt_n, $opt_r);
getopts('hnrs');

# Returns e.g. Wed, 17 Feb 1999 16:50:06 -0500 (EST)
$date = local_date_time();                      # Global.

Help($outgoing_dir, $mailserver) if $opt_h;     # Must come first.
Createnew($date) if $opt_n;
ReplyExisting($replytome, $date) if $opt_r;
# Always check directory for outgoing.
Sendoutgoing($senders_addr, $outgoing_dir);   
# TODO pass params to the spam module.
Getmail($userid, $pw, $mailserver) && spamfilter();
# TODO only cleanup after Getmail??
Cleanup();


sub Sendoutgoing {
  my $senders_addr = $_[0];
  my $outgoing_dir = $_[1];

  my @dircontents  = undef;
  my $count        = 0;
  my $smtp         = undef;

  opendir(OUTDIR, $outgoing_dir) || die "Can't open $outgoing_dir: $!\n";
  # Eliminate . or .. "files"
  @dircontents = grep(!/^..?$/, readdir(OUTDIR));
  closedir(OUTDIR);
  return 0 unless @dircontents;     # No outgoing mail.
  $count = @dircontents;
  if ( $count ) {
    printf("\nDo you want to send existing %s email%s in %s?\n",
                  $count, $count==1 ? "" : "s", $outgoing_dir);
    chomp(my $y_or_n = <STDIN>);
    if ( $y_or_n =~ /y/i ) {   # Send it.
      $smtp = Net::SMTP->new($mailserver,
                             Timeout => 25,
                             Debug   => DEBUG
                             );
      unless ( defined($smtp) ) {
        print "Can't create smtp object.  Mailserver $mailserver may be " .
              "unavailable.  Mail can be sent only from a Mspring "   .
              "dialup.  Continuing with mail retrieval...\n";
        return 1;   # TODO is this right?
      }
      # TODO make this a Sub.
      foreach my $outemail ( @dircontents ) {
        # Prepare to parse outgoing email formatted textfiles.
        my $subjectline = undef;
        my $toline      = undef;
        my $fromline    = undef;
        my $bodylines   = undef;
        my $recip_to    = undef;
        my $recip_cc    = undef;
        my $recip_bcc   = undef;
        my $dateline    = undef;
        my $xmailine    = undef;

        print "DEBUG here's \$outemail:  $outemail\n" if DEBUG;
        print "Banner: ", $smtp->banner();
        #               TODO
        open(OUTGOING, "$outgoing_dir/$outemail") 
                                || die "$0--Can't open $outemail file: $!\n";
        while ( <OUTGOING> ) {
          # Multiple To or Cc will be comma separated.
          if ( $. == 1 )    { chomp($fromline = $_);    next; }
          elsif ( $. == 2 ) { chomp($toline = $_);      next; }
          elsif ( $. == 3 ) { chomp($ccline = $_);      next; }
          elsif ( $. == 4 ) { chomp($bccline = $_);     next; }
          elsif ( $. == 5 ) { chomp($dateline = $_);    next; }
          elsif ( $. == 6 ) { chomp($subjectline = $_); next; }
          elsif ( $. == 7 ) { chomp($xmailine = $_);    next; }
          # The remaining text to EOF is the body.
          else { $bodylines .= $_ }
        }
        close(OUTGOING);

        print "\n\nDEBUG \$senders_addr: $senders_addr\n\n" if DEBUG;
        $smtp->mail($senders_addr);
        $smtpref = \$smtp;
        @sendtos = GenerateTo($toline, $ccline, $bccline, $smtpref);
        # TODO single smtp->to(HERE?)
        for ( @sendtos ) {
          $smtp->to($_);
        }
        # Start the mail
        $smtp->data();                       
        # The next 6 don't affect delivery, they just look pretty.
        $smtp->datasend("$fromline\n");
        $smtp->datasend("$toline\n");  
        $smtp->datasend("$ccline\n") if  $ccline ne 'Cc:';  
        # This is where Bcc would go if it weren't blind.
        $smtp->datasend("$dateline\n");  
        $smtp->datasend("$subjectline\n");
        $smtp->datasend("$xmailine\n\n");    # IMPORTANT double newline
        $smtp->datasend("$bodylines");
        $smtp->dataend();                    # Finish the mail.

        my $tstamp = time();
        system("mv", "$outgoing_dir/$outemail", 
                                "$sent_dir/$outemail$tstamp") unless DEBUG;
        printf("\nMail sent.  Original%s moved to $sent_dir\n",  
                                               @dircontents==1 ? "" : "s");
      }
      $smtp->quit() || die "$0--Can't quit smtp: $!\n"; ;
    }
  }

  return 1;
}


# Retrieve and delete POP mail.
sub Getmail {
  my $userid     = $_[0];
  my $pw         = $_[1];
  my $mailserver = $_[2];

  my $pop = new Mail::POP3Client(USER      => $userid,
                                 AUTH_MODE => 'PASS',
                                 PASSWORD  => $pw,
                                 HOST      => $mailserver
                                );
  print "DEBUG \$userid is $userid\n" if DEBUG;
  print "DEBUG \$mailserver is $mailserver\n" if DEBUG;
  my $mailcount = $pop->Count;
  print "DEBUG \$mailcount is $mailcount\n" if DEBUG;
  # Error indicated by a -1.
  
  die "ERROR -- \$mailcount is $mailcount.  Are you online?  Exiting.\n" 
                                                     if ( $mailcount == -1 ); 
  die "No mail on server.  Exiting.\n" if $mailcount == 0;

  printf("\nRetrieving %d email%s...\n", $mailcount, $mailcount==1 ? "" : "s");

  for ( my $i=1; $i<=$mailcount; $i++ ) {
    my $letter = Ltrnum($i); 
    open(HEADBOD, ">$letter") || die "Can't open: $!\n";
    foreach my $headnbody ( $pop->HeadAndBody($i) ) {
      print HEADBOD "$headnbody\n";
    }
    Progress($mailcount, $i);
    if ( DEBUG ) {
      close(HEADBOD) || print 'DEBUG Trouble closing HEADBOD';
      } else {
      close(HEADBOD) && $pop->Delete($i) 
                   || print 'Trouble deleting from server...';
    }
  }
  $pop->Close;
  # Returned only to allow spamfilter to proceed.
  return $mailcount;
}


# Uniquely identify mail as it is downloaded from mailserver.
sub Ltrnum {
  my $i = $_[0];

  # Allow alphabetical sorting.
  if ( $i < 10 ) { $i = 0 . $i };
 
  # Make unique.
  $i .= "_" . time();
  my $concat = $incoming_dir . '/' . $i . $lettersuffix;

  return $concat;
}


sub Progress {
  my $mailcount = $_[0];
  my $sofar     = $_[1];
  local $|      = 1;    # Avoid buffering problems.

  my $pct = ($sofar / $mailcount) * 100;
  printf("%3.0d%% complete", $pct); 
  sleep(1);
  # Length of progress indicator line is 13.
  print "\b" x 13;    
  return 0;
}


sub Cleanup {
  # Fix Cygwin/Vim term bugs.
  ###$ENV{TERM} = 'xterm';
  system("vi $incoming_dir/*");
  print "Trash email?\n";
  # TODO use varis for paths.
  system('ls -l /home/bheckel/smtpin');
  # TODO use rename instead for portability?
  system('mv /home/bheckel/smtpin/* /home/bheckel/tmp') if <STDIN> =~ /y/i;
  ###$ENV{TERM} = 'cygwin';
  return 0;
}


sub Createnew {
  $rightnow = $_[0];

  # TODO allow To: line completion(s) from passed param.
  my $tstamp = time();
  my $outemail = "$outgoing_dir/emailout$tstamp";
  open(NEWOUTGO, ">$outemail") || die "$0--Can't open file: $!\n";
  print NEWOUTGO <<"EOT";
From: $full_from
To:
Cc:
Bcc:
Date: $rightnow
Subject:
X-Mailer: $XMAIL

EOT
  system("vi $outemail"); #NOT WORKING || die "$0--Can't execute system command: $!\n";
  exit;  # Now user composes email.
}


sub ReplyExisting {
  my $replyto = $_[0];
  my $date    = $_[1];

  my $tstamp = time();
  # Unique outgoing email file.
  my $outemail = "$outgoing_dir/emailout$tstamp";

  open(FIL, $replyto) || die("Can't open file $replyto: $!\n");
  # Assume reply textfiles will be small enough to be accomodated in memory.
  my @wholeorig = <FIL>;
  close(FIL);
  # Insert entire original email sent to you with leading  >  
  foreach $line ( @wholeorig ) {
    # Enquote original text in standard format.
    $line =~ s/^/>/;
    if ( $line =~ m/^>From: +(.*)/ ) {
      # Full English email address line.  E.g. From: Bob Heckel<bheckel@ms.com>
      $fromname = $1;
      print "DEBUG $fromname" if DEBUG;
      next; 
    }
    # Avoid messy multiple Re: RE: ...
    if ( $line =~ /^>Subject: +(.*)/ ) {
      $subj = $1;
      $subj =~ s/(re: )?/RE: /i;
      next;
    }
  }

  open(TXT, ">$outemail") || die("Can't open file $outemail: $!\n");
  print TXT "From: $full_from\n";
  print TXT "To: $fromname\n";
  print TXT "Cc:\n";
  # Returns e.g. Wed, 17 Feb 1999 16:50:06 -0500 (EST)
  print TXT "Date: $date\n";
  print TXT "Subject: $subj\n";
  print TXT "X-Mailer: HeckelMail v2.1:\n\n";
  print TXT "Original message:\n";
  print TXT @wholeorig;
  close(TXT);

  system("vi $outemail");
  exit;
}


# Extract one or more email addresses, using it (them) as the send to
# address(es).
sub GenerateTo {
  # Assumes e.g. ^To: foo@foobar.com, foo2@x.com    with one space after colon.
  my $toline  = $_[0];
  my $ccline  = $_[1];
  my $bccline = $_[2];

  my @toline          = ();
  my @ccline          = ();
  my @bccline         = ();
  my @sendtoaddresses = ();

  #                        remove To:
  @toline = split(/,/, substr($toline,4));
  # Won't always be a Cc: so check for the template line Cc: by itself.
  if ( $ccline ne 'Cc:' ) {
    @ccline = split(/,/, substr($ccline,4));
  }

  # Won't always be a Bcc: so check for the template line Bcc: by itself.
  if ( $bccline ne 'Bcc:' ) {
    @bccline = split(/,/, substr($bccline,5));
  }

  for ( @toline, @ccline, @bccline ) {
    print "DEBUG smtp->to() address is >>> $_ <<<\n" if DEBUG;
    chomp;
    s/\s+//;
    push(@sendtoaddresses, $_); 
  }

  return @sendtoaddresses;
}


sub Help {
  my $smtpout = $_[0];
  my $mailserver = $_[1];
  my $errmsg = $_[2];

  if ( $errmsg ) {
    print "$errmsg.  Exiting.\n";
    exit -1;
  } else {
    print<<"EOT"
$0 $VERSION ($XMAIL) sends, replies to and/or retrieves email.

Without parameters or switches, it promts to send 
any mail in $smtpout, then checks for new mail on 
$mailserver

  -n  Create new message in $outgoing_dir.
      Start typing body immediately after the From: line
      One space after colons.
  -r  Reply to ORIGINALEMAIL (offline operation)
  -h  This message.

EOT
  }
  print "Usage: $0 [-nrh] [ORIGINALEMAIL]\n";
  exit 0;
}

#!/usr/bin/perl -w
##############################################################################
#     Name: reviser-file-ck3.pl
#
#  Summary: Determine if a new extract file(s) has been received by checking
#           timestamps against an existing dbm database.  If a new or newly
#           modified file is found, email the responsible statistian(s) and
#           Vital Support Staff.
#
#           These are sample filenames that we are expecting.  Deviations can,
#           in some cases, cause trouble (e.g. lacking an 'a') but completely
#           bad filenames (i.e. non NCHS states) will be cc:d to IT staff
#           only:
#
#           id05007a.nat.mer
#           ca03030a.dem.mer
#
#           Usually will be run via cron as bqh0 on SunOS 5.8 tstdev:
#           58 * * * * /home/bqh0/bin/reviser-file-ck3.pl --quarterly
#           Periodically make sure tstdev has not been crippled and is unable
#           to email:
#           45 12 * * * uptime | mailx -s "[cron tstdev] load check" 'bqh0@cdc.gov'
#
#           Note: reviserck.pl, reviser-file-ck.pl, reviser-file-ck2.pl are now
#           deprecated.
#
#           Can't use anon arrays due to DBM flattening so code is much
#           messier than it should be.
#
#           ----------------------------------------------
#           View last run's database:
#           echo 'key=val[tstamp,bytes,filename,lastrun tstamp,bytes changed]' && ~/bin/dbmdump.pl ~/dirchgDBM/dir_database | sort
#           or
#           ~/bin/dbmdump.pl ~/dirchgDBM/dir_database | grep ny
#
#           Modify a bad DBM record:
#           dbmmodify.pl ~/dirchgDBM/dir_database flX04nat '1107358575 184362178 fl04032a.nat.mer 1107359100 0'
#
#           Remove a bad DBM record:
#           ~/bin/dbmdel.pl ~/dirchgDBM/dir_database bbX04dem
#            Note: removing a DBM record w/o deleting the actual file will
#            result in the DBM repopulating at the next run.
#           ----------------------------------------------
#
#           Note: if a bad extract is detected, the DBM has to be adjusted
#           manually *after* the fixed good one comes in (at least for now,
#           see TODO below).
#
#           See mailx.fc.tmplt mailx.body.tmplt dbmfix.tmplt in ~ to re-run
#           live email by hand.
#
#           Yearly maintenance -- add NCHS owners for the new calendar year
#           after the DATA line below for both nat and mor.
#
#  Created: Tue 11 May 2004 16:19:14 (Bob Heckel)
# Modified: Mon 19 Jul 2004 14:10:39 (Bob Heckel -- add timestamps)
# Modified: Tue 27 Jul 2004 14:57:24 (Bob Heckel -- mail to statisticians)
# Modified: Wed 01 Sep 2004 13:08:31 (Bob Heckel -- statistician reassignment)
# Modified: Fri 03 Sep 2004 10:11:59 (Bob Heckel -- track by date not size)
# Modified: Tue 07 Sep 2004 10:06:00 (Bob Heckel -- email VSS as well)
# Modified: Thu 09 Sep 2004 15:44:36 (Bob Heckel -- one email per file detect)
# Modified: Tue 28 Sep 2004 12:20:36 (Bob Heckel -- place in production)
# Modified: Tue 19 Oct 2004 09:03:02 (Bob Heckel -- adjust email wording)
# Modified: Mon 08 Nov 2004 10:09:20 (Bob Heckel -- split states are working
#                                     put NCHS on distribution)
# Modified: Tue 07 Dec 2004 14:01:47 (Bob Heckel -- detect all changes and
#                                     note the direction of change per vdj2)
# Modified: Tue 14 Dec 2004 14:12:11 (Bob Heckel -- calculate records instead
#                                     of bytes per kjk4)
# Modified: Tue 14 Dec 2004 16:27:43 (Bob Heckel -- also calculate total
#                                     records based on filesize per kjk4)
# Modified: Tue 04 Jan 2005 12:23:33 (Bob Heckel -- define NCHS owners for
#                                     2005 files)
# Modified: Tue 01 Feb 2005 13:24:56 (Bob Heckel -- modify state assignments)
# Modified: Thu 03 Feb 2005 11:17:14 (Bob Heckel -- modify warning message if
#                                     length calculation is floating point
#                                     number i.e. an error)
# Modified: Mon 14 Feb 2005 10:22:31 (Bob Heckel -- fix problem where junk
#                                     files like .mer interfere with detection
#                                     of new files)
# Modified: Mon 14 Feb 2005 11:15:22 (Bob Heckel -- create failsafe to only
#                                     email a certain number of times)
##############################################################################
use strict;

############################ Toggle ##########################################
use constant DEBUG => 1;         # 1 for production monitoring, 0 disable
# !!! MUST be set to 1 for the first time run when DBM does not yet exist !!!
use constant DEBUGNOEMAIL => 0;  # 1 to not email at all, 0 to send email
use constant DEBUGMUNGE => 0;    # 1 to munge email to bqh0 only, 0 disable
# Use ~/projects/reviserfileck/sim/harness.sh to debug if off tstdev.
use constant DEBUGLOCALPC => 0;  # 1 to run dev tests off tstdev , 0 on tstdev
############################ Toggle ##########################################

use constant NOERROR => 1;       # normal return code
use constant NATLENGTH => 1001;  # bytes
use constant MORLENGTH => 701;   # bytes

my $CLEANRUN = 'yes';  # global

$ARGV[0] ||= '';  # avoid uninitialized warnings during debugging

# Determine dir to watch and where to keep the dbm & timestamp.
my ($watchdir, $dbdir);
if ( $ARGV[0] eq '--quarterly' ) {  # see crontab -e
  $watchdir = '/home/bhb6/data/data1';
  $dbdir = '/home/bqh0/dirchgDBM';     # timestamp/filesize version DBM
} elsif ( $ARGV[0] eq '' ) {  # we're debugging either on PC or tstdev
  if ( DEBUGLOCALPC ) {
    $watchdir = './watchme';
    $dbdir = './dirchgDBM';
  } else {
    $watchdir = '/home/bhb6/data/data1';
    $dbdir = '/home/bqh0/dirchgDBM';
  }
} else {
  die "$0 Error: bad switch $ARGV[0].  Exiting. $!\n";
}
my $dbm = 'dir_database';
my $suffix = '.mer';    # e.g. ny04021a.nat.mer
my $savedtstamp = "$dbdir/lastrun.dat";

# Last run's saved timestamp.
my $lrts;
# Recover the last-run timestamp from disk:
open FH, "$savedtstamp" or warn "WARNING: time stamp file does not exist";
{ local $/ = undef; $lrts = <FH>; }
close FH;

# Statistician and VSS assignments per static data from the mainframe's
# Registers.
my %OWNERS = ();
FillOwnersHash();

# Gather all (old and, if any, new) file names and timestamps.
my %fileattrs = ParseDir($watchdir, $suffix);
my $newfileattrs;  # hashref to hold the new filenames and sizes.
my %dt_nm_bytdiff = ();

# We could have used Storable module instead of DBM to avoid the messy
# splitting of hash key/values but it would not compile on the ancient tstdev.

if ( -e "$dbdir/$dbm.dir" && -e "$dbdir/$dbm.pag" ) {
  # See if new file(s) exist.
  $newfileattrs = Compare("$dbdir/$dbm", \%fileattrs);
  if ( keys %$newfileattrs ) {
    my $diffbytes;  # avoid warnings on never before seen files.
    # We have found 1-newer file(s) or 2-previously non-existant file(s).
    while ( (my $key, my $val) = each %$newfileattrs ) { 
      # E.g.
      # caX03dem002=1102446766 5 ca03002a.dem.mer 1102520871
      # or 
      # caX03dem002=1102446766 5 ca03002a.dem.mer 1102520871 10
      #             ^^^^^^^^^^   ^^^^^^^^^^^^^^^^            ^^
      $newfileattrs->{$key} =~ /(\d+) (\d+) (\S+) \d+ ?(-?\d+)?/;
      $diffbytes = defined $4 ? $4 : $2;
      $dt_nm_bytdiff{$key} = $1 . " " . $3 . " " . $diffbytes;
    }
    my $numsent = 0;
    # Only found one changed file.
    if ( scalar keys %dt_nm_bytdiff == 1 ) {
      Email(\%dt_nm_bytdiff, $lrts, $watchdir);  # just once
    } else {  # more than one new file found (NCHS wants one email per file)
      my %tmp = ();
      while ( (my $key, my $val) = each %dt_nm_bytdiff ) { 
        $numsent++;
        $tmp{$key} = $val;
        # To avoid accidental DOS attack.
        Email(\%tmp, $lrts, $watchdir) if $numsent < 30;
        %tmp = ();
      }
    }
  } else {
    print "NOTHING NEW\n\n" if DEBUG;
  }
  if ( $CLEANRUN eq 'yes' ) {
    UpdateDB("$dbdir/$dbm", $newfileattrs);
  }
} else {  # dbm does not exist
  warn "WARNING: this is probably the first run -- creating " .
        "skeleton db in\n       $dbdir/$dbm\n       to avoid " .
        "failure on subsequent runs.\n\nMake sure DEBUGNOEMAIL is set to 1!!";
  my %DB = ();
  dbmopen %DB, "$dbdir/$dbm", 0644 or warn "can't dbmopen: $!";
  dbmclose %DB;
  open FH, ">$savedtstamp" and 
    warn "WARNING: this is probably the first run -- creating empty ",
         "last run file";
  close FH;
}

# Save current timestamp to disk for next run:
open FH2, ">$savedtstamp" or warn "WARNING: $0: $!";
print FH2 scalar localtime;
close FH2;

exit 0;



############# Subs ##################
#
# Get a real-time ls(1) of the dir and place it into a hash.
sub ParseDir {
  my $dir = shift;
  my $pat = shift;

  open DBGFH, '>/home/bqh0/debug.out' or die "Error: $0: $!";
  print DBGFH "sub parsedir\n";

  opendir DH, "$dir" or die "Can't open $dir: $!\n";
  # E.g. ca03002a.dem.mer but avoid crap like .mer files that are sometimes
  # out there.
  my @ls = grep(/(.+)\.(.+)\.mer$/, readdir(DH));
  # TODO not interpolating
  ###my @ls = grep(/(.+)\.(.+)\.${pat}$/, readdir(DH));
  closedir DH;

  my %h = ();
  my $tstamp;
  my $fsize;
  for ( @ls ) {
    print DBGFH "DEBUG ls: $_\n";
    my $f = "$watchdir/$_";
    $tstamp = (stat($f))[9];
    $fsize = (stat($f))[7];
    print DBGFH "DEBUG fsize: $fsize\n";
    $_ =~ m/(\w\w)(\d\d)(\d+)\w+\.(\w\w\w)${pat}/;
    print DBGFH "DEBUG dollar1-4 $1, $2, $3, $4\n";
    my $s; 
    if ( $1 and $2 and $3 and $4 ) {
      # E.g. idX04dem
      $s = $1 . 'X' . $2 . $4 . $3;
    } else {
      next;
    }
    # Sure could use an anon array...
    $h{$s} = $tstamp . " " . $fsize . " " . $_ . " " . time;
  }

  while ( (my $k, my $v) = each %h ) { print DBGFH "h hash $k=$v\n"; }
  close DBGFH;

  return %h;
}


# Compare previous run's dbm database to current 'ls' output hash ref.
sub Compare {
  my $dbname = shift;  # previous run's dbm file
  my $lshref = shift;  # current run's hash ref

  open DBGFH, '>>/home/bqh0/debug.out' or die "Error: $0: $!";
  print DBGFH "sub compare\n";

  my %DB = ();
  dbmopen %DB, $dbname, 0644 or die "$0: cannot open database $dbname\n";

  if ( DEBUG ) {
    print "x^x^x^x^ prev run \%DB dump x^x^x^x^\n";
    print " key = val[tstamp | bytes | filename | lastrun tstamp | bytes changed]\n";

    foreach my $key (sort { $DB{$a} cmp $DB{$b} } keys %DB) {
      print "$key=$DB{$key}\n";
    }

    print "x^x^x^x^ prev run \%DB dump x^x^x^x^\n\n";
  }

  my @unknownkeys = ();
  my @knownkeys = ();
  foreach my $x ( keys %$lshref ) {
    my $y;
    ###print "\%\$lshref $key=$val\n" if $key =~ /ny/;
    # DBM stores key at a higher level, e.g. mtX04nat
    ($y = $x) =~ s/\d\d\d//;
    # 'known' meaning this state/event already has a record in the DBM.
    push(@knownkeys, $x) if $DB{$y};
    push(@unknownkeys, $x) if ! $DB{$y};
  }

  my %known = ();
  foreach my $x ( @knownkeys ) {
    $known{$x} = $lshref->{$x};
  }

  my %match = ();

  while ( (my $key, my $val) = each %known ) { 
    # Ugly but we can't use anon array refs when using dbm b/c they store
    # as text e.g. 'ARRAY(0xa06260c)' instead of actual refs.
    my ($ts, $fsz, $f) = split /\s/, $val;
    my $x;
    ($x = $key) =~ s/\d\d\d//;
    my ($oldts, $oldfsz, $oldfn, $oldfoundtime) = split /\s/, $DB{$x};
    print DBGFH "DB{x} $DB{$x}\n";
    # Test for newer timestamp than the last time we ran.
    if ( $ts > $oldts ) {
      warn "NEWER STATE/YR/EVENT/FILENUM TIMESTAMP\n$key=$val\n\n" if DEBUG; 
      my $szdiff = $fsz - $oldfsz;
      $match{$key} = $val . " " . $szdiff;
    }
  }

  my %unknown = ();
  foreach ( @unknownkeys ) {
    $unknown{$_} = $lshref->{$_};
  }

  while ( (my $key, my $val) = each %unknown ) { 
    my ($ts, $fsz, $f) = split /\s/, $val;
    print "NEVER SEEN STATE/YR/EVENT/FILENUM BEFORE\n$key=$val\n\n" if DEBUG; 
    $match{$key} = $val;
  }

  dbmclose %DB;

  close DBGFH;

  return \%match;
}


# Prepare for next run by updating a permanent memory of the current state.
sub UpdateDB {
  my $dbname = shift;  # previous run's dbm file to be updated
  my $hr = shift;  # current run's matches hash ref

  my %DB = ();
  dbmopen %DB, $dbname, 0644 or die "$0: cannot open DBM database $dbname\n";

  # Could be multiple files in an hour, store the highest one.
  foreach my $key ( sort keys %$hr ) {
    # Store w/o file number.
    my $shortkey;
    ($shortkey = $key) =~ s/\d\d\d$//;
    ###$DB{$key} = $val;
    $DB{$shortkey} = $$hr{$key};
  }

  if ( DEBUG ) {
    print "\n*-*-*- new \%DB after " . scalar(localtime) . " run-*-*-*\n";
    print " key | tstamp | bytes | filename | lastrun tstamp | bytes changed\n";

    foreach my $key (sort { $DB{$a} cmp $DB{$b} } keys %DB) {
      print "$key=$DB{$key}\n";
    }

    print "*-*-*- new \%DB after this run-*-*-*\n\n";
  }

  dbmclose %DB;

  return NOERROR;
}


# Called once per changed file found.
sub Email {
  my $h = shift;  # filename and size change hash ref
  my $ts = shift; # last run saved-in-textfile timestamp
  my $watchdir = shift;

  my @mailtos = SelectMailTos($h);

  print "\n\nDEBUG: \@mailtos is @mailtos\n";

  my $dbgnote = '';
  if ( DEBUGMUNGE ) {
    print "DEBUGMUNGE is on\n";
    $dbgnote = "\nDEBUGGING IN PROGRESS: If you receive this email, please " .
               "let bqh0\@cdc.gov know.  Thanks!\n";
  } 
  
  my $mailpgm;
  if ( DEBUGNOEMAIL ) {
    print "DEBUGNOEMAIL is on\n";
    return NOERROR; # and don't actually send any mail
  } else {
    if ( DEBUGMUNGE ) {
      $mailpgm = "mailx -s 'A new reviser file has been created since $ts' 'bqh0\@cdc.gov'";
    } else {
      $mailpgm = "mailx -s 'A new reviser file has been created since $ts' -r LMITHELP\@cdc.gov -c 'bboswell\@cdc.gov bheckel\@cdc.gov' '@mailtos'";
      ###$mailpgm = "mailx -s 'A new reviser file has been created since $ts' -r LMITHELP\@cdc.gov -c bheckel\@cdc.gov' '@mailtos'";
    }
  }

  my $rnd = int(rand(time)) + 1;

  if ( ! DEBUGLOCALPC ) {
    open MAILHANDLE, "|$mailpgm" || die "$0 can't fork for mailx: $!";
    print MAILHANDLE "This file has been created by the Unix/Sybase system " .
                     "in Hyattsville:\n\n";
  } elsif ( DEBUGLOCALPC ) {
    print "DEBUGLOCALPC is on\n";
    open MAILHANDLE, ">./dummyemail$rnd" or die "Error: $0: $!";
    print MAILHANDLE "\n**********email would start********\n";
  }

  # Iterate the changed/new file.
  while ( (my $key, my $val) = each %$h ) { 
    # E.g. $val: 1102538286 pa03018a.nat.mer -10
    $val =~ m/(\d+) (\S+\.(\w+)\.\w+) (-?\d+)/;
 print "0DEBUG val: $val\n";
    my $tstmp = scalar localtime $1;
    my $fnm = $2;
    my $evt = $3;
print "0.5DEBUG4dollar: $4\n";
    my $bytchange = $4;

    # TODO this is hacked due to changes requested after datastructures were
    # set in stone -- need to somehow add size to the hash received
    my $bytsize = (stat("$watchdir/$fnm"))[7];

    if ( DEBUG ) {
      print "DEBUG:\$key: $key [\$1:$1] [\$2:$2]\n\t\t\t[\$3:$3] [\$4:$4]\n";
    }

    my ($rtot, $rchg);

    if ( $bytchange > 0 ) {
      $rtot = CalcRecs($bytsize, $evt);
print "1DEBUGbytchange: $bytchange\n";
print "2DEBUGevt: $evt\n";
print "2.5DEBUGrtot: $rtot\n";
      $rchg = CalcRecs($bytchange, $evt);
print "3DEBUGrtot: $rchg\n";
      print MAILHANDLE SizeDiffMsg($rtot, $rchg, $fnm, $tstmp, $bytchange);
    } elsif ( $bytchange < 0 ) {
      (my $abs = $bytchange, $evt) =~ s/^-//;
      $rtot = CalcRecs($bytsize, $evt);
      $rchg = CalcRecs($abs, $evt);
      print MAILHANDLE SizeDiffMsg($rtot, $rchg, $fnm, $tstmp, $bytchange);
    } elsif ( $bytchange == 0 ) {
      print MAILHANDLE "$fnm $tstmp\n\nNOTE: This file is EQUAL IN SIZE to the " .
            "last file that was transferred\n";
    } else {
      print MAILHANDLE "$0 ERROR: please reply to this email " .
            "\$1:$1 \$2:$2 \$3:$3 \$4:$4\n" .
            "\$tstmp = $tstmp \$fnm = $fnm \$bytchange = $bytchange\n";
      }
  }
  
  print MAILHANDLE <<"EOT";
$dbgnote  
Please copy and paste the above filename into FCAST's REVISER MENU screen if you'd like to to process the file and produce the TSA.


If you have any questions or need assistance, just reply to this email. 



Here is a step-by-step example of the process to produce a forecast table:

1-   Statistician and specialist receive this automated email notification - highlight the file name and select edit/copy
2-   Logon mainframe into ISPF
3-   Type =6
4-   Type "fcast"
5-   Select option 6 - Reviser Menu
6-   Select option 6 - Transfer File From Unix And Produce Report 
7-   Paste the file name copied from above into the text field
8-   Usually you will want "PRINTER" to be left as is, "MAIL"
9-   Tab to the submit "button", press enter
10-  You will receive an email containing a link to the report.  If the file is large this could take an hour or so.

EOT

  if ( ! DEBUGLOCALPC ) {
    close MAILHANDLE;
  }

  return NOERROR;
}


# Add size info to the email.
sub SizeDiffMsg {
  my $rtot = shift;
  my $rchg = shift;
  my $fnm = shift;
  my $tstmp = shift;
  my $bytchange = shift;

  # Defensive default.
  my $msg = 'ERROR, please reply to this email for assistance';
  my $warn = <<"EOT1";
$fnm $tstmp

NOTE: Cannot calculating size.  
EOT1

  # Uh oh, found a floating point change number.
  if ( $rchg =~ /\d*\.\d+/ ) {
    print "DEBUG: rchg $rchg\n";

    # A bad run will ruin all future good runs so set flag to not update DBM.
    ###$CLEANRUN = 'no';
    # TODO dilemma - A. if don't update, user gets email every time this runs,
    # B. if do update, the next true run fails wrongly.  We're going with B
    # for now -- manual cleanup *will* be required e.g.
    # ~/bin/dbmdel.pl ~/dirchgDBM/dir_database bbX04nat
    $CLEANRUN = 'yes';
    return $warn;
  }

  my $nocommachg;
  my $nocommatot;
  ($nocommachg = $rchg) =~ s/,//g;
  ($nocommatot = $rtot) =~ s/,//g;
  my $r1 = $nocommachg!=1 ? 'records' : 'record';
  my $r2 = $nocommatot!=1 ? 'records' : 'record';

  # Remove sign.
  $rchg =~ s/-//g;

  if ( $bytchange < 0 ) {
    $msg = "contains $rtot $r1 and is $rchg $r2 SMALLER than";
  } elsif ( $bytchange > 0 ) {
    $msg = "contains $rtot $r1 and is $rchg $r2 LARGER than";
  } else {
    $msg = 'is EQUAL IN SIZE to';
  }

  my $str = <<"EOT2";
$fnm $tstmp

NOTE: This file $msg the last file that was transferred
EOT2

  $CLEANRUN = 'yes';

  return $str;
}

# Called once per detected new file.
sub SelectMailTos {
  my $h = shift;  # e.g. key ycX04dem, val (ignored) 1093015688

  my @addresses = ();

  for ( keys %$h ) {
    my $ss = substr $_, 0, 2;
    my $yy = substr $_, 3, 2;
    my $evt = substr $_, 5, 3;
    push @addresses, $OWNERS{$ss}->{$evt}->{$yy}->{stati};
    push @addresses, $OWNERS{$ss}->{$evt}->{$yy}->{vss};
  }

  my @fulladdresses = ();

  # Add CDC domain suffixes.
  for my $uid ( @addresses ) {
    $uid =~ s#(\w+)#$1\@cdc.gov#;
    push @fulladdresses, $uid;
  }

  return @fulladdresses;
}


# Turn bytes into record counts since we know what the line lengths should be.
# E.g. mi04025a.dem.mer is 52340165 bytes, mi04024a.dem.mer was 50998451 so
# 52340165/701 is 74665 tot recs and (52340165-50998451)/701 is 1914 recs
# added.
sub CalcRecs {
  my $bytes = shift;
  my $evt = shift;

  return 0 if $bytes == 0;

  my $recs;

  if ( $evt eq 'nat' ) {
    $recs = $bytes / NATLENGTH;
  }
  elsif ( $evt eq 'dem' ) {
    $recs = $bytes / MORLENGTH;
  } else {
    return 0;
  }

  # Comma-fy
  $recs = reverse $recs;
  $recs =~ s<(\d\d\d)(?=\d)(?!\d*\.)><$1,>g;

  return scalar reverse $recs;
}


# Fill a hash of anonymous hashes of anonymous hashes which will look like
# this:
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
# %OWNERS = ( ak => {
#                     nat => { 
#                              '03' => {stati => 'alm5', vss => 'slm5'}, 
#                              '04' => {stati => 'bxj9', vss => 'slm8'}, 
#                            },
#                     dem => { 
#                              '03' => {stati => 'bxj9', vss => 'cmk1'}, 
#                              '04' => {stati => 'dwj2', vss => 'slm6'}, 
#                            },
#                   },
#             az => {
#                     nat => { 
#                              '03' => {stati => 'vdj2', vss => 'slm5'}, 
#                              '04' => {stati => 'alm6', vss => 'cmd6'}, 
#                            },
#                     dem => { 
#                              '03' => {stati => 'almy', vss => 'slm6'}, 
#                              '04' => {stati => 'vdj2', vss => 'mbj1'}, 
#                            },
#                   },
#            ...
#           );
#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#
sub FillOwnersHash {
  while ( <DATA> ) {
    next if /^$/;
    my ($vss, $stat, $st, $evt, $yy) = split;
      $OWNERS{$st}->{$evt}->{$yy}->{stati} = $stat;
      $OWNERS{$st}->{$evt}->{$yy}->{vss} = $vss;
  }
}


# Pasted-in data from whohas.sas, all years for each event:
__DATA__
  pyh9        bxj9         ak       nat    03
  pyh9        vdj2         al       nat    03
  pyh9        bxj9         ar       nat    03
  cmc6        vdj2         as       nat    03
  cmc6        vdj2         az       nat    03
  slm6        dwj2         ca       nat    03
  mbj1        alm5         co       nat    03
  ckj1        bxj9         ct       nat    03
  pyh9        alm5         dc       nat    03
  pyh9        vdj2         de       nat    03
  ckj1        dwj2         fl       nat    03
  slm6        dwj2         ga       nat    03
  mbj1        vdj2         gu       nat    03
  pyh9        alm5         hi       nat    03
  mbj1        bxj9         ia       nat    03
  pyh9        alm5         id       nat    03
  mbj1        bxj9         il       nat    03
  pyh9        dwj2         in       nat    03
  mbj1        alm5         ks       nat    03
  cmc6        bxj9         ky       nat    03
  slm6        vdj2         la       nat    03
  mbj1        vdj2         ma       nat    03
  ckj1        dwj2         md       nat    03
  pyh9        vdj2         me       nat    03
  cmc6        bxj9         mi       nat    03
  mbj1        bxj9         mn       nat    03
  cmc6        alm5         mo       nat    03
  slm6        vdj2         mp       nat    03
  pyh9        bxj9         ms       nat    03
  mbj1        dwj2         mt       nat    03
  mbj1        alm5         nc       nat    03
  mbj1        bxj9         nd       nat    03
  cmc6        bxj9         ne       nat    03
  cmc6        vdj2         nh       nat    03
  slm6        vdj2         nj       nat    03
  cmc6        alm5         nm       nat    03
  slm6        bxj9         nv       nat    03
  pyh9        dwj2         ny       nat    03
  cmc6        vdj2         oh       nat    03
  cmc6        vdj2         ok       nat    03
  mbj1        alm5         or       nat    03
  ckj1        vdj2         pa       nat    03
  slm6        bxj9         pr       nat    03
  slm6        alm5         ri       nat    03
  ckj1        bxj9         sc       nat    03
  mbj1        alm5         sd       nat    03
  slm6        alm5         tn       nat    03
  cmc6        dwj2         tx       nat    03
  mbj1        alm5         ut       nat    03
  pyh9        dwj2         va       nat    03
  pyh9        vdj2         vi       nat    03
  cmc6        alm5         vt       nat    03
  slm6        alm5         wa       nat    03
  slm6        alm5         wi       nat    03
  slm6        bxj9         wv       nat    03
  cmc6        bxj9         wy       nat    03
  slm6        dwj2         yc       nat    03
  pyh9        ces0         ak       nat    04
  pyh9        ces0         al       nat    04
  pyh9        bxj9         ar       nat    04
  cmc6        vdj2         as       nat    04
  cmc6        vdj2         az       nat    04
  slm6        dwj2         ca       nat    04
  mbj1        alm5         co       nat    04
  ckj1        kjk4         ct       nat    04
  pyh9        alm5         dc       nat    04
  pyh9        vdj2         de       nat    04
  ckj1        dwj2         fl       nat    04
  slm6        dwj2         ga       nat    04
  mbj1        vdj2         gu       nat    04
  pyh9        alm5         hi       nat    04
  mbj1        bxj9         ia       nat    04
  pyh9        alm5         id       nat    04
  mbj1        bxj9         il       nat    04
  pyh9        ces0         in       nat    04
  mbj1        alm5         ks       nat    04
  cmc6        bxj9         ky       nat    04
  slm6        ces0         la       nat    04
  mbj1        vdj2         ma       nat    04
  ckj1        dwj2         md       nat    04
  pyh9        vdj2         me       nat    04
  cmc6        bxj9         mi       nat    04
  mbj1        bxj9         mn       nat    04
  cmc6        alm5         mo       nat    04
  slm6        vdj2         mp       nat    04
  pyh9        bxj9         ms       nat    04
  mbj1        dwj2         mt       nat    04
  mbj1        kjk4         nc       nat    04
  mbj1        bxj9         nd       nat    04
  cmc6        bxj9         ne       nat    04
  cmc6        vdj2         nh       nat    04
  slm6        kjk4         nj       nat    04
  cmc6        ces0         nm       nat    04
  slm6        ces0         nv       nat    04
  pyh9        kjk4         ny       nat    04
  cmc6        vdj2         oh       nat    04
  cmc6        vdj2         ok       nat    04
  mbj1        alm5         or       nat    04
  ckj1        kjk4         pa       nat    04
  slm6        bxj9         pr       nat    04
  slm6        ces0         ri       nat    04
  ckj1        kjk4         sc       nat    04
  mbj1        alm5         sd       nat    04
  slm6        kjk4         tn       nat    04
  cmc6        dwj2         tx       nat    04
  mbj1        alm5         ut       nat    04
  pyh9        ces0         va       nat    04
  pyh9        vdj2         vi       nat    04
  cmc6        alm5         vt       nat    04
  slm6        alm5         wa       nat    04
  slm6        alm5         wi       nat    04
  slm6        bxj9         wv       nat    04
  cmc6        bxj9         wy       nat    04
  slm6        dwj2         yc       nat    04
  pyh9        ces0         ak       nat    05
  pyh9        ces0         al       nat    05
  pyh9        bxj9         ar       nat    05
  cmc6        vdj2         as       nat    05
  cmc6        vdj2         az       nat    05
  slm6        dwj2         ca       nat    05
  mbj1        alm5         co       nat    05
  ckj1        kjk4         ct       nat    05
  pyh9        alm5         dc       nat    05
  pyh9        vdj2         de       nat    05
  ckj1        dwj2         fl       nat    05
  slm6        dwj2         ga       nat    05
  mbj1        vdj2         gu       nat    05
  pyh9        alm5         hi       nat    05
  mbj1        bxj9         ia       nat    05
  pyh9        alm5         id       nat    05
  mbj1        bxj9         il       nat    05
  pyh9        ces0         in       nat    05
  mbj1        alm5         ks       nat    05
  cmc6        bxj9         ky       nat    05
  slm6        ces0         la       nat    05
  mbj1        vdj2         ma       nat    05
  ckj1        dwj2         md       nat    05
  pyh9        vdj2         me       nat    05
  cmc6        bxj9         mi       nat    05
  mbj1        bxj9         mn       nat    05
  cmc6        alm5         mo       nat    05
  slm6        vdj2         mp       nat    05
  pyh9        bxj9         ms       nat    05
  mbj1        dwj2         mt       nat    05
  mbj1        kjk4         nc       nat    05
  mbj1        bxj9         nd       nat    05
  cmc6        bxj9         ne       nat    05
  cmc6        vdj2         nh       nat    05
  slm6        kjk4         nj       nat    05
  cmc6        ces0         nm       nat    05
  slm6        ces0         nv       nat    05
  pyh9        kjk4         ny       nat    05
  cmc6        vdj2         oh       nat    05
  cmc6        vdj2         ok       nat    05
  mbj1        alm5         or       nat    05
  ckj1        kjk4         pa       nat    05
  slm6        bxj9         pr       nat    05
  slm6        ces0         ri       nat    05
  ckj1        kjk4         sc       nat    05
  mbj1        alm5         sd       nat    05
  slm6        kjk4         tn       nat    05
  cmc6        dwj2         tx       nat    05
  mbj1        alm5         ut       nat    05
  pyh9        ces0         va       nat    05
  pyh9        vdj2         vi       nat    05
  cmc6        alm5         vt       nat    05
  slm6        alm5         wa       nat    05
  slm6        alm5         wi       nat    05
  slm6        bxj9         wv       nat    05
  cmc6        bxj9         wy       nat    05
  slm6        dwj2         yc       nat    05
  pyh9        bxj9         ak       dem    03
  pyh9        vdj2         al       dem    03
  pyh9        bxj9         ar       dem    03
  cmc6        vdj2         as       dem    03
  cmc6        vdj2         az       dem    03
  slm6        dwj2         ca       dem    03
  mbj1        alm5         co       dem    03
  ckj1        bxj9         ct       dem    03
  pyh9        alm5         dc       dem    03
  pyh9        vdj2         de       dem    03
  ckj1        dwj2         fl       dem    03
  slm6        dwj2         ga       dem    03
  mbj1        vdj2         gu       dem    03
  pyh9        alm5         hi       dem    03
  mbj1        bxj9         ia       dem    03
  pyh9        alm5         id       dem    03
  mbj1        bxj9         il       dem    03
  pyh9        dwj2         in       dem    03
  mbj1        alm5         ks       dem    03
  cmc6        bxj9         ky       dem    03
  slm6        vdj2         la       dem    03
  mbj1        vdj2         ma       dem    03
  ckj1        dwj2         md       dem    03
  pyh9        vdj2         me       dem    03
  cmc6        bxj9         mi       dem    03
  mbj1        bxj9         mn       dem    03
  cmc6        alm5         mo       dem    03
  slm6        vdj2         mp       dem    03
  pyh9        bxj9         ms       dem    03
  mbj1        dwj2         mt       dem    03
  mbj1        alm5         nc       dem    03
  mbj1        bxj9         nd       dem    03
  cmc6        bxj9         ne       dem    03
  cmc6        vdj2         nh       dem    03
  slm6        vdj2         nj       dem    03
  cmc6        alm5         nm       dem    03
  slm6        bxj9         nv       dem    03
  pyh9        dwj2         ny       dem    03
  cmc6        vdj2         oh       dem    03
  cmc6        vdj2         ok       dem    03
  mbj1        alm5         or       dem    03
  ckj1        vdj2         pa       dem    03
  slm6        bxj9         pr       dem    03
  slm6        alm5         ri       dem    03
  ckj1        bxj9         sc       dem    03
  mbj1        alm5         sd       dem    03
  slm6        alm5         tn       dem    03
  cmc6        dwj2         tx       dem    03
  mbj1        alm5         ut       dem    03
  pyh9        dwj2         va       dem    03
  pyh9        vdj2         vi       dem    03
  cmc6        alm5         vt       dem    03
  slm6        alm5         wa       dem    03
  slm6        alm5         wi       dem    03
  slm6        bxj9         wv       dem    03
  cmc6        bxj9         wy       dem    03
  slm6        dwj2         yc       dem    03
  pyh9        ces0         ak       dem    04
  pyh9        ces0         al       dem    04
  pyh9        bxj9         ar       dem    04
  cmc6        vdj2         as       dem    04
  cmc6        vdj2         az       dem    04
  slm6        dwj2         ca       dem    04
  mbj1        alm5         co       dem    04
  ckj1        kjk4         ct       dem    04
  pyh9        alm5         dc       dem    04
  pyh9        vdj2         de       dem    04
  ckj1        dwj2         fl       dem    04
  slm6        dwj2         ga       dem    04
  mbj1        vdj2         gu       dem    04
  pyh9        alm5         hi       dem    04
  mbj1        bxj9         ia       dem    04
  pyh9        alm5         id       dem    04
  mbj1        bxj9         il       dem    04
  pyh9        ces0         in       dem    04
  mbj1        alm5         ks       dem    04
  cmc6        bxj9         ky       dem    04
  slm6        ces0         la       dem    04
  mbj1        vdj2         ma       dem    04
  ckj1        dwj2         md       dem    04
  pyh9        vdj2         me       dem    04
  cmc6        bxj9         mi       dem    04
  mbj1        bxj9         mn       dem    04
  cmc6        alm5         mo       dem    04
  slm6        vdj2         mp       dem    04
  pyh9        bxj9         ms       dem    04
  mbj1        dwj2         mt       dem    04
  mbj1        kjk4         nc       dem    04
  mbj1        bxj9         nd       dem    04
  cmc6        bxj9         ne       dem    04
  cmc6        vdj2         nh       dem    04
  slm6        kjk4         nj       dem    04
  cmc6        ces0         nm       dem    04
  slm6        ces0         nv       dem    04
  pyh9        kjk4         ny       dem    04
  cmc6        vdj2         oh       dem    04
  cmc6        vdj2         ok       dem    04
  mbj1        alm5         or       dem    04
  ckj1        kjk4         pa       dem    04
  slm6        bxj9         pr       dem    04
  slm6        ces0         ri       dem    04
  ckj1        kjk4         sc       dem    04
  mbj1        alm5         sd       dem    04
  slm6        kjk4         tn       dem    04
  cmc6        dwj2         tx       dem    04
  mbj1        alm5         ut       dem    04
  pyh9        ces0         va       dem    04
  pyh9        vdj2         vi       dem    04
  cmc6        alm5         vt       dem    04
  slm6        alm5         wa       dem    04
  slm6        alm5         wi       dem    04
  slm6        bxj9         wv       dem    04
  cmc6        bxj9         wy       dem    04
  slm6        dwj2         yc       dem    04
  pyh9        ces0         ak       dem    05
  pyh9        ces0         al       dem    05
  pyh9        bxj9         ar       dem    05
  cmc6        vdj2         as       dem    05
  cmc6        vdj2         az       dem    05
  slm6        dwj2         ca       dem    05
  mbj1        alm5         co       dem    05
  ckj1        kjk4         ct       dem    05
  pyh9        alm5         dc       dem    05
  pyh9        vdj2         de       dem    05
  ckj1        dwj2         fl       dem    05
  slm6        dwj2         ga       dem    05
  mbj1        vdj2         gu       dem    05
  pyh9        alm5         hi       dem    05
  mbj1        bxj9         ia       dem    05
  pyh9        alm5         id       dem    05
  mbj1        bxj9         il       dem    05
  pyh9        ces0         in       dem    05
  mbj1        alm5         ks       dem    05
  cmc6        bxj9         ky       dem    05
  slm6        ces0         la       dem    05
  mbj1        vdj2         ma       dem    05
  ckj1        dwj2         md       dem    05
  pyh9        vdj2         me       dem    05
  cmc6        bxj9         mi       dem    05
  mbj1        bxj9         mn       dem    05
  cmc6        alm5         mo       dem    05
  slm6        vdj2         mp       dem    05
  pyh9        bxj9         ms       dem    05
  mbj1        dwj2         mt       dem    05
  mbj1        kjk4         nc       dem    05
  mbj1        bxj9         nd       dem    05
  cmc6        bxj9         ne       dem    05
  cmc6        vdj2         nh       dem    05
  slm6        kjk4         nj       dem    05
  cmc6        ces0         nm       dem    05
  slm6        ces0         nv       dem    05
  pyh9        kjk4         ny       dem    05
  cmc6        vdj2         oh       dem    05
  cmc6        vdj2         ok       dem    05
  mbj1        alm5         or       dem    05
  ckj1        kjk4         pa       dem    05
  slm6        bxj9         pr       dem    05
  slm6        ces0         ri       dem    05
  ckj1        kjk4         sc       dem    05
  mbj1        alm5         sd       dem    05
  slm6        kjk4         tn       dem    05
  cmc6        dwj2         tx       dem    05
  mbj1        alm5         ut       dem    05
  pyh9        ces0         va       dem    05
  pyh9        vdj2         vi       dem    05
  cmc6        alm5         vt       dem    05
  slm6        alm5         wa       dem    05
  slm6        alm5         wi       dem    05
  slm6        bxj9         wv       dem    05
  cmc6        bxj9         wy       dem    05
  slm6        dwj2         yc       dem    05

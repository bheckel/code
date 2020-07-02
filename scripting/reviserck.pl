OBSOLETE
#!/usr/bin/perl 
##############################################################################
#     Name: reviserck.pl
#
#  Summary: Determine if a new merge file has been received by checking its
#           name and then making sure it's a larger file (hopefully ignoring
#           "reloads")
#
#  Created: Tue 11 May 2004 16:19:14 (Bob Heckel)
# Modified: Mon 19 Jul 2004 14:10:39 (Bob Heckel -- add timestamps)
# Modified: Tue 27 Jul 2004 14:57:24 (Bob Heckel -- mail to statisticians)
# Modified: Wed 01 Sep 2004 13:08:31 (Bob Heckel -- statistician reassignment)
##############################################################################
use strict;
use constant DEBUG => 1;
use constant NOERROR => 1;

my %stats = ( alm5 => [ 'co', 'dc', 'hi', 'id', 'ks', 'mo', 'nc',
                        'or', 'sd', 'ut', 'vt', 'wa', 'wi'
                      ],
              bxj9 => [ 'ar', 'ct', 'ia', 'il', 'ky', 'mi', 'mn',
                        'ms', 'nd', 'ne', 'pr', 'wv', 'wy'
                      ],
              ces0 => [ 'al', 'ak', 'in', 'la', 'nv', 'nm', 'ri', 'vi' ],
              dwj2 => [ 'ca', 'fl', 'ga', 'md', 'mt', 'tx',
                        'va', 'wc', 'yc'
                      ],
              kjk4 => [ 'pa', 'sc', 'ny', 'tn' ],
              vdj2 => [ 'as', 'az', 'de', 'gu', 'ma', 'me',
                        'mp', 'nh', 'nj', 'oh', 'ok', 
                      ],
            );

my ($watchdir, $mailto, $dbdir);
if ( $ARGV[0] eq '--hourly' ) {
  $watchdir = '/home/bhb6/data/data1';
  $dbdir = '/home/bqh0/dirchg2';
  $mailto = 'bhb6@cdc.gov,bqh0@cdc.gov';
} elsif ( $ARGV[0] eq '' ) {
  ###$watchdir = './dir2ck';
  $watchdir = '/home/bqh0/dirchgDEB/watchme';
  ###$dbdir = './database';
  $dbdir = '/home/bqh0/dirchgDEB';
  $mailto = 'bqh0';
} else {
  die "Error: bad switch $ARGV[0].  Exiting\n";
}
my $dbm = 'dir_database';
my $suffix = '.mer';    # e.g. ny04021a.nat.mer
my $savedtstamp = "$dbdir/lastrun.dat";

my $ts;
# Recover the last-run timestamp from disk:
open FH, "$savedtstamp" or warn "ERROR: $0: $!";
{ local $/ = undef; $ts = <FH>; }
close FH;

# Gather file names and sizes.
my %h = ParseDir($watchdir, $suffix);

my $hr;  # hashref to hold the new filenames and sizes.
my %fnameonly = ();  # key e.g. ycX04dem and val yc04010a.dem.mer

# Would have used Storable module instead of dbm to avoid the messy splitting
# of hash key/values but it would not compile on tstdev.

# See if new or larger files exist.
if ( -e "$dbdir/$dbm.dir" && -e "$dbdir/$dbm.pag" ) {
  $hr = Compare("$dbdir/$dbm", \%h);
  if ( keys %$hr ) {
    while ( (my $key, my $val) = each %$hr ) { 
      if ( DEBUG ) {
        warn "\nFound new or larger: $key / $val\n"; 
      }
      $hr->{$key} =~ /.* (.*)/;
      $fnameonly{$key} = $1;
    }
    Email(\%fnameonly, $mailto, $ts);
    UpdateDB("$dbdir/$dbm", $hr);
  }
} else {
  warn "ERROR: this is probably the first run -- creating " .
        "skeleton db in\n       $dbdir/$dbm\n       to avoid " .
        "failure on subsequent runs.\n";
  my %DB = ();
  dbmopen %DB, "$dbdir/$dbm", 0644 or die "can't dbmopen: $!";
  dbmclose %DB;
  exit 1;
}

# Save the timestamp to disk for next run:
open FH2, ">$savedtstamp" or die "Error: $0: $!";
print FH2 scalar localtime;
close FH2;

exit 0;



############# Subs ##################
#
# Get a real-time ls of the dir.  Place into a hash datastructure like this:
# 2 char state abbrev, X, 2 digit year, 3 char event, size in bytes
# E.g. caX04dem 323
sub ParseDir {
  my $dir = shift;
  my $pat = shift;

  opendir DH, "$dir" or die "Can't open $dir: $!\n";
  my @newls = grep(/${pat}$/, readdir(DH));
  closedir DH;

  my %h = ();
  my $size;
  for ( @newls ) {
    my $f = "$watchdir/$_";
    $size = (stat($f))[7];
    # E.g. sc04006a.nat.mer
    $_ =~ m/(\w\w)(\d\d).*\.(\w\w\w)\.mer/;
    my $s = $1 . 'X' . $2 . $3;
    $h{$s} = $size . " " . $_;
  }

  return %h;
}


# Compare previous run's dbm database to current 'ls' output hash ref.
sub Compare {
  my $dbname = shift;  # previous run's dbm file
  my $lshref = shift;  # current run's hash ref

  my %DB = ();
  dbmopen %DB, $dbname, 0644 or die "$0: cannot open database $dbname\n";

  if ( DEBUG ) {
    print "***prev run db***\n";
    while ( (my $key, my $val) = each %DB ) { print "$key=$val\n"; }
    print "***prev run db***\n";
    print "********curr files***********\n";
    while ( (my $key, my $val) = each %$lshref ) { 
      print "$key=$val\n"; 
    }
    print "********curr files***********\n\n";
  }

  my @unknown = ();
  my @known = ();
  foreach (keys %$lshref) {
    push(@unknown, $_) if $DB{$_} eq '';
    push(@known, $_) if $DB{$_} ne '';
  }

  my %known = ();
  foreach ( @known ) {
    $known{$_} = $lshref->{$_};
  }

  my %match = ();

  while ( (my $key, my $val) = each %known ) { 
    # Messy but we can't use anon array refs when using dbm b/c they store
    # as text e.g. 'ARRAY(0xa06260c)' instead of actual refs.
    my ($sz, $f) = split /\s/, $val;
    if ( $sz > $DB{$key} ) {
      warn "BIGGER $key=$val\n" if DEBUG; 
      # E.g. ycX04dem = 12345 yc04051a.dem.mer;
      $match{$key} = $val;
    }
  }

  my %unknown = ();
  foreach ( @unknown ) {
    $unknown{$_} = $lshref->{$_};
  }

  while ( (my $key, my $val) = each %unknown ) { 
    my ($sz, $f) = split /\s/, $val;
    print "UNKNOWN $key=$val\n" if DEBUG; 
    $match{$key} = $val;
  }

  dbmclose %DB;

  return \%match;
}


# Prepare for next run by updating a fairly permanent memory of what existed
# last time.
sub UpdateDB {
  my $dbname = shift;  # previous run's dbm file to be updated
  my $hr = shift;  # current run's matches hash ref

  my %DB = ();
  dbmopen %DB, $dbname, 0644 or die "$0: cannot open database $dbname\n";

  while ( (my $key, my $val) = each %$hr ) {
    # We don't care about filenames wrt the dbm.
    # E.g. 64 nd04007a.dem.mer becomes 64
    $val =~ s/\s.*//;
    $DB{$key} = $val;
  }

  if ( DEBUG ) {
    print "***NEW db********\n";
    while ( (my $key, my $val) = each %DB ) { print "$key=$val\n"; }
    print "***NEW db********\n";
  }

  dbmclose %DB;

  return NOERROR;
}


sub Email {
  my $h = shift;
  my $mailto = shift;
  my $ts = shift;

  my @mailtos = ChooseStatisticians($h);

  my ($mail, $singplur, $qty);
  if ( scalar keys %$h == 1 ) {
    $mail = "mailx -s 'A new reviser file has been created since $ts' $mailto";
    $singplur = 'This file has';
    $qty = '';     
  } else {
    $mail = "mailx -s 'New reviser files have been created since $ts' $mailto";
    $singplur = 'These files have'; 
    $qty = 's';
  }

  open MAILHANDLE, "|$mail" || die "$0 can't fork for mailx: $!";

  print MAILHANDLE "$singplur been created in $watchdir\n\n";
  my $fqn;
  my $mtime;
  while ( (my $key, my $val) = each %$h ) { 
    my $ts = scalar localtime((stat "$watchdir/$val")[9]);
    print MAILHANDLE "$val $ts\n";
  }
  
  print MAILHANDLE <<"EOT";
  

You may contact LMITHelp to produce the table$qty
Or
Use FCAST -- Reviser Menu to transfer the file and produce the report


DEBUG: this email would have been sent to:
@mailtos


This is an automated email.  Please contact LMITHELP if you have any questions
EOT

  close MAILHANDLE;

  return NOERROR;
}


sub ChooseStatisticians {
  my $h = shift;

  my @a = ();
  my @addresses = ();
  my $x;

  while ( (my $key, my $val) = each %$h ) { 
    ($x = $key) =~ s/(..).*/$1/;
    push @a, $x;
  }

  # Each element in hash
  while ( (my $key, my $val) = each %stats ) {
    # Each element in hash's anon array
    for my $state ( @{$val} ) {
      # Each element in normal wanted array
      for my $s ( @a ) {
        # Compare what hash has with what we want
        if ( $s eq $state ) {
          warn "found -- $key owns $state\n" if DEBUG;
          push @addresses, $key;
        }
      }
    }
  }

  # Don't want multiple emails to go out if we find more than one file for one
  # statistician.
  my @unique = keys %{ { map {$_ => 1} @addresses } };

  return @unique;
}



__END__
dbmcreate.pl:

dbmopen %DB, "./database/dir_database", 0644 or die "can't dbmopen: $!";

print "creating database...\n";
$DB{ncX03dem} = 123;
$DB{paX03dem} = 223;
$DB{caX03nat} = 320;
$DB{caX04nat} = 323;
$DB{caX04dem} = 423;

dbmclose %DB;

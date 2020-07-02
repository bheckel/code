#!/usr/bin/perl
##############################################################################
# Program Name: online
#
#      Summary: Time online sessions and provide report.
#               TODO make q as a result of nm95's nh disconnect signal.
#
#      Created: Sat May 01 1999 19:45:56 (Bob Heckel)
#     Modified: Wed Jun 02 1999 18:45:23 (Bob Heckel--1st day of mo missed if
#                                         don't get online.)
#     Modified: Sat Jun 05 1999 12:58:27 (Bob Heckel--fix if day of mo is less
#                                         than 4, help usage, display hrs/mins
#                                         and wrap NetMail with this pgm.)
#     Modified: Sun, 08 Aug 1999 16:06:54 (Bob Heckel--shorten mtd switch,
#                                          accept any key to quit)
##############################################################################

# TODO -n not working...

$timername = '/home/bheckel/timer_mspring';

# If it's the first of the mo, del the old ini file.
# TODO automate unlinking and reporting final total for mo.
$dayofmo = (localtime)[3];
if ($dayofmo < 4) {
print "WARNING: Delete timer_mspring file to prepare for new month.\n"};

&timeit unless @ARGV;

if ($ARGV[0] eq '-r') {
  &rport;
} elsif ($ARGV[0] eq '-m') { 
  &mtd;
} elsif ($ARGV[0] eq '--help') { 
  print "Usage: online without param starts timer. Type q to stop.\n";
  print "       online --help   prints this help screen\n";
  print "       online -r  prints report on month's usage.\n";
  print "       online -m  prints time spent online month-to-date.\n";
  print "       online -n  runs NetMail and starts timer.  Type q to stop.\n";
} elsif ($ARGV[0] eq '-n') {
  # Alias exists in /bin
  system("nmail");
  &timeit;
}

sub timeit {
  # E.g. 925578409 seconds since 1970 epoch.
  $start = time();
  # User now online for x seconds...
  $closeme = <STDIN>;
  chomp $closeme;
  if ($closeme =~ /[a-zA-Z]/) { 
    $finish = time();
    $elapsed = ($finish - $start);
  }
  open(INI, ">>$timername");
  print INI "$elapsed\n";
  close(INI);
}

sub rport {
  # TODO Use format...
  print "report due any day now.\n";
}

sub mtd {
  # Create it if deleted as a result of Day 1 of month, otherwise append to
  # it.
  open(INI, "$timername");
  $secstodate = 0;
  # Read then sum each line containing seconds per online session.
  while (<INI>) {
  $secstodate += $_;
  }
  close(INI);
  print "$secstodate seconds or\n";
  # Get minutes online -- numeric.
  $convrtmin = &secs2mins($secstodate);
  # TODO use Perl Reports format.
  print $convrtmin;
  # Get hours and mins online -- string.
  $convrthr = &secs2hrs($secstodate);
  print $convrthr;
}

sub secs2mins {
  # Receives seconds.
  # Convert seconds into minutes.
  my $secsin = $_[0];
  $mins = ($secsin / 60);
  $wordmins = $mins . " minutes or\n";
  return $wordmins;
}

sub secs2hrs {
  # Receives seconds.
  # TODO should I be using round instead of int's truncation?
  # Convert seconds to hours and minutes -- string.
  my $secsin = $_[0];

  # 60 for seconds, 60 for mins, gives hrs.
  $hrswithdec = ((($secsin / 60) / 60));
  $hrswithoutdec = int(($secsin / 60) / 60);
  $fractmin = ($hrswithdec - $hrswithoutdec);

  # 0.01667 is fraction of hr represented by 1 min.
  # TODO need round here, not int, what is Perl's round??
  $mins = int($fractmin / 0.01667);
  $wordhrsmins = $hrswithoutdec . " hours and " . $mins . " minutes.\n";
  return $wordhrsmins;
}


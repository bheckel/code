#!/usr/bin/perl -w
##############################################################################
#     Name: query_mysql_db.fuzz3.pl
#
#    EXPERIMENTAL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
#
#  Summary: Query data fuzzily in a MySQL database.  Separate hits and misses
#           into two files and report the results.
#
#           Looks at the raw concatenated Ind and Occ literal, tries to
#           natural language match the db's concatenated Ind and Occ literals.
#           This query returns a small set of possibilities (instead of
#           blindly searching all 1M records on each iteration of the
#           inputfile).  
#
#           MySQL does a bad job of natural matching *but* if
#           used as input for String::Similarity comparisons, it is probably
#           accurate enough and much faster than the partitioned database
#           approach used in query_mysql_db.fuzz.pl.
#
#        TODO add indicator (or use separate file?) on all non-exact match
#        successes (e.g. farmer farming will fuzzy score 1 but farmerr
#        farmingg will be < 1).  Let that be a way for human review to take
#        place. 
#
#  Created: Fri 13 Sep 2002 13:53:25 (Bob Heckel) 
# Modified: Fri 15 Nov 2002 12:22:57 (Bob Heckel)
##############################################################################
use strict qw(refs vars);
use DBI();
use String::Similarity;
use IOCODE_util;

##################Config##########################
use constant DEBUG      => 1;
use constant TBLNAME    => 'iando';
###use constant INPUTFILE  => '/home/bqh0/tmp/nomatch.occrestrict.out';
use constant INPUTFILE  => '/home/bqh0/tmp/smallBENtest.txt';
use constant OUTPUTFILE => '/home/bqh0/tmp/match.fuzz.out333';
# This holds all misses from the other 7 passes.
use constant NOMATCHF   => '/home/bqh0/tmp/nomatch.fuzz.out333';
use constant CONFIDENCE => '0.90';
use constant MAX_CHILDPROCESSES => 5;
##################Config##########################

my $t1 = time();
my ($dbh1, $dbh2, $dbh3, $dbh4, $dbh5);
my %PID_TO_LINE = ();  # key=PID value=line
my %LINE_RESULT = ();  # key=line value=0(no error) or 1(error)
# Cleanup from previous run.
unlink OUTPUTFILE or warn "OUTPUTFILE not available to delete.  Continuing.\n";  
unlink NOMATCHF or warn "NOMATCHF not available to delete.  Continuing.\n";  
print "Creating " . OUTPUTFILE . " (matches) and\n" . NOMATCHF . 
                            " (misses) from\n" .  INPUTFILE . " (input)\n";

# Overall stats:
my $tot_ctr = 0;
my $match_ctr = 0;
my $miss_ctr = 0;

open IN, INPUTFILE or die "Error: $0: $!";
while ( <IN> ) {
  $_ =~ s/[\r\n]+$//;  # chomp
  my ($f1, $f2, $f3, $f4, $f5, $f6, $ilit, $olit) = split "\t", $_;
  my $rawfused = join ' ', $ilit, $olit;
  print "examining rawfused($.): $rawfused\n";

  Wait_for_kid() if keys %PID_TO_LINE >= MAX_CHILDPROCESSES;
  if ( my $pid = fork() ) {
    # PARENT does...
    # Coordination. 
    # The keys of this hash will be the child process ID, and the value will
    # be the corresponding line that the child is processing.  
    $PID_TO_LINE{$pid} = $_;
    print "child $pid created, now processing \"$PID_TO_LINE{$pid}\"\n";
  } else {
    # CHILD does...
    # The work. 
    # Run query on each line in IN to generate possibilities, then run
    # similarity() to get matches.
###    if ( DoFuzz($rawfused, $ilit, $olit, $f1, $f2, $f3, $f4, $f5, $f6) ) {
###      $match_ctr++;
###      $tot_ctr++;
###    } else {
###      $miss_ctr++;
###      $tot_ctr++;
###    }
    # Rely on DBI's error handling if this fails.
    $dbh1 = DBI->connect($connect_str, $user, $pw, \%rerr);
    $dbh2 = DBI->connect($connect_str, $user, $pw, \%rerr);
    $dbh3 = DBI->connect($connect_str, $user, $pw, \%rerr);
    $dbh4 = DBI->connect($connect_str, $user, $pw, \%rerr);
    $dbh5 = DBI->connect($connect_str, $user, $pw, \%rerr);

    my $yyz = keys %PID_TO_LINE;
    DoFuzz($rawfused, $ilit, $olit, $yyz, $f1, $f2, $f3, $f4, $f5, $f6);
    exit;
  }
}

1 while Wait_for_kid();  # final reap

close IN && print "IN closed\n";
print "tot: $tot_ctr\t match: $match_ctr\t miss: $miss_ctr\n";
print time() - $t1;

exit 0;


# Receive a single fused line, an iliteral, an oliteral and the broken-out
# pieces (whose values are garbage to me) of the line that will be needed to
# write the Misses file.  Query the db for a close "natural" match then find
# the best similarity(), returning true if matched.
sub DoFuzz {
  my $rawfused = shift;  # concatenated line
  my $ilit = shift;      # literal string
  my $olit = shift;      # occ string
  my $numch = shift;
  my ($f1, $f2, $f3, $f4, $f5, $f6) = @_; # unused pieces for the missing file

  my $foundone   = 0;     # found match flag
  my $hiscore    = 0;     # highest so far
  my $currscore  = 0;     # floating pt number betw CONFIDENCE and 1.0 
  my $match      = 0;     # boolean
  my $bestdb     = undef; # best match string literal found in database
  my $bestdbinum = 0;     # ind code from database
  my $bestdbonum = 0;     # occ code from database

  # MySQL "natural language" query to avoid looking at a million lines for each
  # line of Dorothy's file.
  my $sql =  qq/
               SELECT CONCAT(indliteral, ' ', occliteral) AS 
                                        dbfused, indnum, occnum 
               FROM @{[ TBLNAME ]}
               WHERE MATCH (indliteral, occliteral) AGAINST (?)
             /;

  my $sth = undef;
  ###my $sth = $dbh->prepare($sql);
  if ( $numch == 0 ) {
    $sth = $dbh1->prepare($sql);
    $sth->execute(uc $rawfused);
  } elsif ( $numch == 1 ) {
    $sth = $dbh2->prepare($sql);
    $sth->execute(uc $rawfused);
  } elsif ( $numch == 2 ) {
    $sth = $dbh3->prepare($sql);
    $sth->execute(uc $rawfused);
  } elsif ( $numch == 3 ) {
    $sth = $dbh3->prepare($sql);
    $sth->execute(uc $rawfused);
  } elsif ( $numch == 4 ) {
    print "DEBUG: $numch\n";
    $sth = $dbh4->prepare($sql);
    $sth->execute(uc $rawfused);
  } else {
    warn "error: unknown \$numch: $numch\n";
    $sth = $dbh5->prepare($sql);
    $sth->execute(uc $rawfused);
  }

  ###$sth->execute(uc $rawfused);
  # Perl Arrays run faster than hashes (at the expense of clarity).
  ###while ( my $ref = $sth->fetchrow_hashref() ) {
  while ( my $ref = $sth->fetchrow_arrayref() ) {
    # $currscore will never be '1' in IOCODE b/c the previous query steps have
    # already captured direct matches.  If the design of IOCODE ever changes,
    # it would be good to drop out of this loop as soon as 1 (exact fuzz
    # match) is found.
    ###$currscore = similarity($rawfused, $ref->{dbfused}, CONFIDENCE);
    $currscore = similarity($rawfused, $ref->[0], CONFIDENCE);

    ###print "$ENV{fg_blue}Candidate:$ENV{normal} $ref->[0] is $currscore\n" 
                                          ###if $currscore > CONFIDENCE;
    if ( $currscore > $hiscore ) {
      $hiscore = $currscore;
      ###$bestdb = $ref->{dbfused};
      $bestdb = $ref->[0];
      ###$bestdbinum = $ref->{indnum};
      $bestdbinum = $ref->[1];
      ###$bestdbonum = $ref->{occnum};
      $bestdbonum = $ref->[2];
    }
  }

  if ( $hiscore >= CONFIDENCE) {
    $foundone = 1;
    $match++;
    print "$ENV{fg_yellow}Best$ENV{normal}> $hiscore $bestdb is $bestdbinum " 
                     . " and $bestdbonum  $ENV{fg_yellow}<Best$ENV{normal}\n";
    open RESULTSFILE, '>>'.OUTPUTFILE || die "$0: can't open file: $!\n";
    print RESULTSFILE "$rawfused\t$bestdbinum\t$bestdbonum\n";
    close RESULTSFILE || die "cannot close RESULTSFILE: $!\n";
  }

  unless ( $foundone ) {
    open MISSFILE, '>>'.NOMATCHF || die "$0: can't open file: $!\n";
    print MISSFILE "$f1\t$f2\t$f3\t$f4\t$f5\t$f6\t$ilit\t$olit\n";
    close MISSFILE || die "cannot close MISSFILE $!\n";
  }

  ###$dbh->disconnect();

  return $match;  # boolean
}


# Wait for child process to be reaped.
sub Wait_for_kid {
  my $pid = wait();  # gets child pid as reaped
  return 0 if $pid < 0;
  my $line = delete $PID_TO_LINE{$pid}
                         or print "uh oh, why did i see $pid($?)\n", next;
  print "Wait_for_kid(): reaping $pid, now exhausted.\n";
  ###warn "Wait_for_kid(): reaping $pid, now exhausted after working " .
  ###"on \"$line\" \n";
  $LINE_RESULT{$line} = $? ? 0 : 1;

  return 1;  # reaped successfully
}

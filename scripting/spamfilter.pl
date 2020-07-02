#!/usr/bin/perl -w
##############################################################################
#     Name: spamfilter.pl 1.4
#
#  Summary: Spamfilter for NetMail95 / Vim on Win95.
#           Runs via nv alias.
#
#  Adapted: Sat, 25 Mar 2000 22:19:17 (Bob Heckel -- from My Life with Spam
#                                     article Mark-Jason Dominus)
# Modified: Thu, 15 Jun 2000 22:40:51 (Bob Heckel)
##############################################################################

use Coy;

$smtpin = '/home/bheckel/smtpin';
$smtpspam = '/home/bheckel/smtpspam';

opendir(SMTPIN, $smtpin);
@files = grep(/txt$/, readdir(SMTPIN));


foreach $file ( @files ) {
  # Clear so that trapping missing TO's works.
  %hdrs = ();
  # TODO how to use?  Although I do enjoy the Coy warnings...
  ###local $^W = 0;
  open(FILE, $smtpin . '/' . $file) || die "Can't open: $!\n";
  while (<FILE>) {
    { 
      local $/ = ""; 
      $header = <FILE>; 
      # Not used but pgm fails without it.
      undef $/; 
      $body = <FILE>; 
    }
    # Clean spamreport since some TO lines have trailing \n.
    # TODO why doesn't it work??
    ###chomp;
    # It says that the delimiters between header lines aren't \n characters;
    # just an \n by itself isn't enough. (?!foo) says that in order to match,
    # perl must not see foo coming up at that position in the string. (?!\s)
    # says that the next character after the \n must not be a whitespace
    # character. So where /\n/ will match any newline character, /\n(?!\s)/
    # will only match the newline characters that are not immediately
    # followed by whitespace. These are precisely the ones that are at the
    # ends of logical lines. 
    @logical_hdrlines = split /\n(?!\s)/, $header;

    foreach $line (@logical_hdrlines) {
      # Cut each line into two pieces. The /:\s*/ says that the pieces will
      # be separated by a : followed by some white space; For the header line
      # Date: Thu, 10 Apr 97 01:00:43 EST this places Date into $label and
      # Thu, 10 Apr 97 01:00:43 EST into $value.  Notice that Perl does not
      # split on the :'s in the date; that's because the 2 in the split tells
      # Perl that there are only two fields here, so that it ignores any :'s
      # after the first one. 
      my ($label, $value) = split /:\s*/, $line, 2;
      $label = uc($label);
      $hdrs{$label} = $value;
    }

    # Trap 1:
    # Catch mail not specifically addressed to me (or w/o any To:).
    # TODO this multi OR needs help.
    unless ( (exists $hdrs{TO}) && 
             ($hdrs{TO} =~ /rsh\@technologist|bheckel\@mindspring|cygnus|perl|sfnb/) ) {
      push(@likelyspam, "$smtpin/$file");

      # spamreport.txt is deleted after each email fetch.
      open(SUMMARY, ">>$smtpin/spamreport.txt") || die "Can't open: $!\n";
      print SUMMARY "$smtpspam/$file :", $hdrs{SUBJECT}, "\n";
      close(SUMMARY);
    }
    # return ?? next ?? avoid double entries in @likelyspam??
    ###last if ( @likelyspam );

    # TODO
    # Trap 3:
    # Catch mail based on know spammer domains.
    ###$recvd = $hdrs{RECEIVED};
    ###print $recvd;
    ###my($user, $site) = $recvd =~ /(.*)@(.*)/;
    ###my ($user, $site) = $s =~ /(.*)@(.*)/;
    ###next unless $site;
    ###my @components =  split(/\./, $site);
    ###my $n_comp = ($components[-1] =~ /^edu|com|net|org|gov$/) ? 2 : 3;
    ###my $domain = lc(join '.', @components[-$n_comp .. -1]);
    ###$domain =~ s/^\.//;  # Remove leading . if there is one.
    ###print "domain $domain\n";
    ###push(@likelyspam, "/home/bheckel/smtpin/$file") 
      ###        if ( $domain =~ /exactis/ );

    # Have filenames 001234.txt, 001235.txt, etc. and "Free Money".
    ###&trapped(@likelyspam, $hdrs{SUBJECT});
  }
  close(FILE) || die "Can't close: $!\n";
}

# Toss likely spam into temp area to review (and purge) occasionally.
foreach ( @likelyspam ) {
  print 'Likely spam:', $_, "\n";
  system("mv $_ $smtpspam/")
}

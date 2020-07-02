#!/usr/bin/perl -w
##############################################################################
#    Name: wordfreq (s/b symlinked as wordcount)
#
# Summary: Count word frequency of words occurring more than user-specified
#          times.
#
#          Sample output:
#          value key 
#          523 spam
#           13 money
#
# TODO allow case sensitivity switch
# TODO min number of appearnaces (but using head(1) might be easier)
# TODO allow to work as filter
# TODO minappear as a cmdline parm
#
# Adapted: Mon, 21 Feb 2000 21:55:46 (Bob Heckel from Perl Cookbook)
# Modified: Mon, 04 Dec 2000 09:40:32 (Bob Heckel)
##############################################################################

###Usage($0, '') if ( $ARGV[0] =~ /-+h.*/ );

###$ARGV[1] ? $minappear = $ARGV[1] : $minappear = 1;
###$minappear ||= $ARGV[1];
use constant USAGEMSG => <<USAGE;
Usage: wordfreq [-h] FILENAME
       Count frequency of word occurrences
USAGE

die USAGEMSG if ( $ARGV[0] =~ /-+h.*/ );

%seen = ();
$minappear = 4;
while ( <> ) {
  while ( /(\w['\w-]*)/g ) {
    # Use each word as the key and increment the value by one.
    $seen{lc $1}++;
  }
}

foreach $word ( sort { $seen{$b} <=> $seen{$a} } keys %seen ) {
  if ( $seen{$word} > $minappear ) {
    printf "%5d %s\n", $seen{$word}, $word;
  }
}

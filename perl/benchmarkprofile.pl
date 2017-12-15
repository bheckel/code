#!/usr/bin/perl -w

# Quick alternative - call sub 100 times, and time it
# use Benchmark; timethis(100, "MySub()"); 


# Time the differences in algorithms. From Perl FAQ.  And SysAdmin Magazine.

use Benchmark qw(cmpthese);

###@junk = `cat ~/tmp/testing/junk`;
###
###timethese(1_500_000, {
###                       'map' => sub { 
###                                  my @a = @junk;
###                                  map { s/a/b/ } @a;
###                                  return @a
###                                },
### 
###                       'for' => sub { 
###                                  my @a = @junk;
###                                  local $_;
###                                  for ( @a ) { s/a/b/ };
###                                  return @a 
###                                },
###                     }
###);

# or another e.g.:


my $URI = "http://www.stonehenge.com/perltraining/";

sub re_match {
  my $str = $URI;
  my ($scheme, $rest) = $str =~ /(.*?):(.*)/;
}

sub split_it {
  my $str = $URI;
  my ($scheme, $rest) = split /:/, $str, 2;
}

sub index_substr {
  my $str = $URI;
  my $pos = index($str, ":");
  my $scheme = substr($str, 0, $pos-1);
  my $rest = substr($str, $pos+1);
}


# Comparisons are done in pairs, negatives are better.
cmpthese(-2, {
  re_match => \&re_match,
  split_it => \&split_it,
  index_substr => \&index_substr,
  }
);

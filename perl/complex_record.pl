#!/usr/bin/perl -w
##############################################################################
#     Name: complex_record.pl
#
#  Summary: Demo of using a reference to store complex records.
#
#  Adapted: Tue 30 Dec 2003 11:03:10 (Bob Heckel --
#        file:///C:/Perl/html/lib/Pod/perldsc.html#more_elaborate_records)
##############################################################################
###use strict;

########################################
# Load from variable:
my $tv = {
  flintstones => {
    series   => 'flintstones',
    nights   => [ qw(monday thursday friday) ],
    members  => [
      { name => 'fred',    role => 'lead', age => 36, },
      { name => 'wilma',   role => 'wife', age => 31, },
      { name => 'pebbles', role => 'kid',  age =>  4, },
    ],
  },

  jetsons => {
    series   => 'jetsons',
    nights   => [ qw(wednesday saturday) ],
    members  => [
      { name => 'george', role => 'lead', age => 41, },
      { name => 'jane',   role => 'wife', age => 39, },
      { name => 'elroy',  role => 'kid',  age =>  9, },
    ],
  },

  simpsons => {
    series   => 'simpsons',
    nights   => [ qw(monday) ],
    members  => [
      { name => 'homer', role => 'lead', age => 34, },
      { name => 'marge', role => 'wife', age => 37, },
      { name => 'bart',  role => 'kid',  age => 11, },
    ],
  },
};

print $tv->{flintstones}{series}, "\n";
print $tv->{flintstones}{nights}[1], "\n";
print $tv->{jetsons}{members}[1]{age}, "\n";


########################################
# Load from file:
# TODO looks messy

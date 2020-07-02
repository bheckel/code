#!/usr/bin/perl -w

my $stagedir = 'c:/cygwin/home/rsh86800/tmp/1345143810_16Aug12/tmp/';
my $procdir = 'c:/cygwin/home/rsh86800/tmp/1345143810_16Aug12/tmp/tmp2/';
opendir DH, "$stagedir" or die "Error: $0: $!";
my @files = grep { !/^..?$/ && !-d } map "$stagedir/$_", readdir DH;

while ( my @smallchunks = splice @files, 0, 5 ) {
  foreach $f ( @smallchunks ) {
    print "$f\n";
    # Windows
###    system("cp $f $procdir");
    system('cp', '-v', "$f" , $procdir);
  }

  print "\n!!!run merps and sleep\n";
###  system('D:\Merps_Apps\Links\LK500300.exe');
  sleep 2;
}

#!/usr/bin/perl -w

use Getopt::Std;
use Digest::MD5 qw(md5); 

@statnames = qw(dev ino mode nlink uid gid rdev size mtime
        ctime blksize blocks md5);
getopt('p:c:');
die "Usage: $0 [-p <filename>|-c <filename>]\n"
    unless ($opt_p or $opt_c);
if ($opt_p){
    die "Unable to stat file $opt_p:$!\n" unless (-e $opt_p);
    open(F,$opt_p) or die "Unable to open $opt_p:$!\n";
    $digest = Digest::MD5->new->addfile(F)->hexdigest;
    close(F);
    print $opt_p,"|",join('|',(lstat($opt_p))[0..7,9..12]),"|$digest","\n";
    exit;
}
if ($opt_c){
    open(CFILE,$opt_c) or die "Unable to open check file $opt_c:$!\n";
    while (<CFILE>){
        chomp;
        @savedstats = split('\|');
        die "Wrong number of fields in \'$savedstats[0]\' line.\n"
            unless ($#savedstats == 13); 

        @currentstats = (lstat($savedstats[0]))[0..7,9..12];
        open(F,$savedstats[0]) or die "Unable to open $opt_c:$!\n";
        push(@currentstats,Digest::MD5-& gt;new->addfile(F)->hexdigest);
        close(F);
        &printchanged(\@savedstats,\ @currentstats)
            if ("@savedstats[1..13]" ne "@currentstats");
    }
    close(CFILE);
} 

sub printchanged {
    my($saved,$current)= @_;
    print shift @{$saved},":\n";
    for (my $i=0; $i <= $#{$saved};$i++){
        if ($saved->[$i] ne $current->[$i]){
            print " ".$statnames[$i]." is now ".$current->[$i];
            print " (".$saved->[$i].")\n";
        }
    }
} 


undef $/;          # read in whole file, not just one line or paragraph

open my $read, '<', '/mnt/nfs/home/bheckel/code/misccode/bladerun_crawl' or die "Error: $0: $!";

while ( <$read> ) {
    while ( /strength(.*?)engineers/sgm ) { # /s makes . cross line boundaries
      print "$1\n";
    }
}

#!/usr/bin/perl -w
##############################################################################
#     Name: tar_percentage.pl
#
#  Summary: Take a pecentage of a large directory structure, usually for
#           testing purposes.
#
# Created: Mon 29 Oct 2001 11:22:51 (Bob Heckel)
##############################################################################

###opendir(DIRHANDLE, '/home/bheckel/tmp/testing') || die "$!\n";
opendir(DIRHANDLE, '//j') || die "$!\n";
# Skip dotfiles.
@files = grep(!/^..?$/, readdir(DIRHANDLE));
$i = 0;
$j = 0;

for ( @files ) {
  # Only want directories, ignoring loose files at root level.
  next unless -d  $_;
  $i++;
  if ( $i % 20 == 0 ) {
    print "dir to be tarred: $_\n";  
    system("tar --append --file=/i/tmp/foo.tar $_") && die "tar error $!\n";
    $j++;
  }
}

$pct = $j/$i;

print "\ndirectories tarred: $pct\n";

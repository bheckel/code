#!/usr/bin/perl -w
##############################################################################
#     Name: traverse_dirs.pl
#
#  Summary: Recurse (descend) a directory, looking for all files from that root
#           downward.  Recursive.
#
#           Can't 'use strict' very easily.
#
#           DEPRECATED - see filefind.pl or bobackup.pl
#
#           For single directory, just use:
#  my @files = grep { !/^..?$/ && !-d } map "$_", readdir DH;
#
#  Adapted: Wed, 07 Feb 2001 13:09:18 (Bob Heckel from Mark Hewett's
#                                      traverse_dirs.pl
# Modified: Thu, 15 Feb 2001 08:55:57 (Bob Heckel)
##############################################################################

@x = Traverse('//c/todel/subcollapse');

for ( @x ) {
  print "$_\n";
}


sub Traverse {
  my $dir = shift;

  opendir($dir, $dir) || die "Cannot open $dir: $!";
  
  while ( $dirent = readdir($dir) ) {
    # Throw out '.' and '..'
    next if (($dirent eq ".") || ($dirent eq ".."));

    $path = $dir."/".$dirent;
    push(@path, $path);
    
    # Recurse for directories.
    Traverse($path) if (-d $path);
  }
  closedir($dir);
  
  return @path;
}


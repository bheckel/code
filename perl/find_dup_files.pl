#!/usr/bin/perl -w
##############################################################################
#     Name: find_dup_files.pl 
#
#  Summary: Recurse a directory, printing attributes of dups, if any.
#
#  Created: Fri 16 Nov 2001 14:58:22 (Mark Hewett)
# Modified: Sat 28 Sep 2002 12:27:06 (Bob Heckel) 
##############################################################################

#------------------
# Pedantic version:
#------------------

use TimeLib;

# Fill the %fsystem hash.
Traverse('/home/bheckel/tmp/testing');

foreach $f ( keys %fsystem ) { 
  #                 |array of hash refs|
  @location_list = @{$fsystem{$f}};
  if ( @location_list > 1 ) {
    print "name=", $f, "\n";
    foreach $finfo ( @location_list ) {
      %fileattrs = %$finfo;
      printf("  dir=%s size=%s date=%s\n", $fileattrs{dir},
                                           $fileattrs{size},
                                           cvtime($fileattrs{date}),)
    }
  }
}


sub Traverse {
  my $dir = shift;

  opendir($dir, $dir) || die "Cannot open $dir: $!";
  
  while ( $dirent = readdir($dir) ) {
    # Throw out '.' and '..'
    next if (($dirent eq ".") || ($dirent eq ".."));

    $path = $dir."/".$dirent;
    
    if (-d $path) {
      # Recurse for directories.
      Traverse($path);
    }
    else {
      ($fsize, $mtime) = (stat $path)[7, 9];
      push @{$fsystem{$dirent}}, { dir=>$dir, size=>$fsize, date=>$mtime };
    }
  }

  closedir($dir);
  
  return @path;
}


#----------------------
# More concise version.
#----------------------

###use TimeLib;
###
###Traverse('/home/bheckel/tmp/testing/xdir');
###
###foreach $f ( keys %fsystem ) { 
###  if ( @{$fsystem{$f}} > 1 ) {
###      print $f,"\n";
###      foreach $finfo (@{$fsystem{$f}}) {
###        printf("  dir=%s size=%s date=%s\n",
###        $finfo->[0],
###        $finfo->[1],
###        cvtime($finfo->[2]),
###        )
###      }
###    }
###  }
###}
###
###
###sub Traverse {
###  my $dir = shift;
###
###  opendir($dir, $dir) || die "Cannot open $dir: $!";
###  
###  while ( $dirent = readdir($dir) ) {
###    # Throw out '.' and '..'
###    next if (($dirent eq ".") || ($dirent eq ".."));
###
###    $path = $dir."/".$dirent;
###    
###    if (-d $path) {
###      # Recurse for directories.
###      Traverse($path);
###    }
###    else {
###      ($fsize, $mtime) = (stat $path)[7, 9];
###      push @{$fsystem{$dirent}}, [$dir, $fsize, $mtime];
###    }
###  }
###
###  closedir($dir);
###  
###  return @path;
###}


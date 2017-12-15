#!/usr/bin/perl -w
##############################################################################
#    Name: mkdir_build
#
# Summary: Mkdir a long path.
#          TODO only builds from root (i.e. / )
#
# Created: Fri, 06 Oct 2000 14:31:23 (Bob Heckel)
##############################################################################

use strict;

# Starts at / in the filesystem.
buildlongpath('/very/long/foo.txt');

sub buildlongpath {
  my $dir_and_name = $_[0];
  my $confirm_root = $_[1];

  my ($dir, $file) = $dir_and_name =~ m!(.*/)(.*)!s;

  if ( !-d $dir ) {
    # Build path incrementally.
    my $longerpath = "";
    my $sofar      = "";

    my @pathpieces = split(/\//, $dir);

    foreach my $piece ( @pathpieces ) {
      next if $piece eq "";
      my $sofar = $longerpath . '/' . $piece . '/';
      # User's umask can make this more restrictive.
      mkdir($sofar, 0777) || die "Can't make $dir: $!\n";
      $longerpath = $sofar;
      $sofar = "";
    }
    return 0;
  } else {
    print "Directory $dir already exists.  Exiting.\n";
  }
}

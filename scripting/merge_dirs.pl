#!/usr/bin/perl -w
##############################################################################
#    Name: merge_dirs.pl
#
# Summary: Compare the contents of 2 directories, writing the most recent 
#          files to a third, possibly new, directory.  Requested by Jon Dalmas.
#
# Created: Wed, 01 Nov 2000 09:56:59 (Bob Heckel)
# Modified: Mon 14 Oct 2013 08:27:45 (Bob Heckel)
##############################################################################

use File::Copy;
use File::Basename;

my $me = basename($0);
$me =~ s/\./_/g;

Usage() unless ( $#ARGV > 0 );
Usage() if ( $ARGV[0] =~ /^-+h.*/ );

$i = 0;
$dir1 = $ARGV[0];
$dir2 = $ARGV[1];
$ARGV[2] ? ($dir3 = $ARGV[2]) : ($dir3 = $me);

opendir(DIRHANDLE, $dir1) || die "Can't access directory $dir1: $!";
@files1 = readdir(DIRHANDLE); close(DIRHANDLE);
@files1clean = grep { !/^\.+$/ } @files1;  # no dotfiles
%fhash1 = map {$_ => 1} @files1clean;

opendir(DIRHANDLE, $dir2) || die "Can't access directory $dir2: $!;";
@files2 = readdir(DIRHANDLE); close(DIRHANDLE);
@files2clean = grep { !/^\.+$/ } @files2;
%fhash2 = map {$_ => 1} @files2clean;

mkdir($dir3) || die "Can't create directory $dir3: $!\n";

@both   = grep { $fhash1{$_} }  @files2clean;
@unique = grep { !$fhash2{$_} } @files1clean;
push(@unique, grep { !$fhash1{$_} } @files2clean);

my $cnt=@both+@unique;
print "\n$cnt files found (in both dirs)\n\n";

foreach my $duplicate ( @both ) {
  my $fromdir1 = $dir1 . '/' . $duplicate;
  my $fromdir2 = $dir2 . '/' . $duplicate;

  my $fromdir1stat = (stat($fromdir1))[9];
  my $fromdir2stat = (stat($fromdir2))[9];

  die "Unexpected error during stat(). Exiting\n" unless $fromdir1stat;
  die "Unexpected error during stat(). Exiting\n" unless $fromdir2stat;

  if ( $fromdir1stat > $fromdir2stat ) {
    copy($fromdir1, $dir3); 
    print "Dup found-copied newer from DIRECTORY1: $fromdir1 \n";
    $i++;
  } else {
    copy($fromdir2, $dir3); 
    print "Dup found-copied newer from DIRECTORY2: $fromdir2\n";
    $i++;
  }
}

foreach my $discrete ( @unique ) {
  $fullpath1 = $dir1 . '/' . $discrete;
  $fullpath2 = $dir2 . '/' . $discrete;

  if ( -e $fullpath1 ) {
    copy($fullpath1, $dir3); 
    print "Copied unique file from DIRECTORY1: $fullpath1\n";
    $i++;
  }
  elsif ( -e $fullpath2 ) {
    copy($fullpath2, $dir3); 
    print "Copied unique file from DIRECTORY2: $fullpath2\n";
    $i++;
  } 
  else {
    die "Unexpected error during unique copy.  Exiting\n";
  }
}

print "\n$i files copied successfully to directory $dir3/\n";


sub Usage {
  print <<"EOT";
Usage: $0 [-q] DIRECTORY1 DIRECTORY2 [DIRECTORY3]
           -q   quiet mode [TODO]

Summary:
  Copies the most recent version of files from either DIRECTORY1
  or DIRECTORY2 into DIRECTORY3.  Creates directory
    ./$me
  if you do not specify DIRECTORY3.
EOT
  exit -1;
}

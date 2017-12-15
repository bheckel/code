#!/usr/bin/perl -w
##############################################################################
#    Name: separate_arr_file_dir.pl
#
# Summary: Separate the files from the subdirectories in a directory.
#          Distinguish between files and directories using both short and
#          long (fully qualified) names.
#
# Created: Thu, 01 Feb 2001 09:49:37 (Bob Heckel)
##############################################################################

use File::Find;

$fqpath = '/home/bheckel/todel/collapse/subcollapse/';

opendir(DIR, $fqpath) || die "Can't open: $!\n";
@files = grep(!/^..?$/, readdir DIR);
closedir(DIR);

# For demo purposes.
foreach $file ( @files ) {
  $file = $fqpath . $file;
}

# No descending if prune is true.
find sub { $File::Find::prune = 1; sort(push(@d, $File::Find::name)) if -d }, @files;
find sub { $File::Find::prune = 1; sort(push(@f, $File::Find::name)) unless -d }, @files;

print "fq dirs:\t @d\n";
print "\n";
print "fq files:\t @f\n";
print "\n";

for ( @d ) {
  $shortd = $1 if m|[/\\:]+([^/\\:]+)$|;
  print "short dir:\t $shortd\n";
}

for ( @f ) {
  $shortf = $1 if m|[/\\:]+([^/\\:]+)$|;
  print "short file:\t $shortf\n";
}


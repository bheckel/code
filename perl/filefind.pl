#!/usr/bin/perl -w
##############################################################################
#    Name: filefind.pl
#
# Summary: Demo of recursive subdirectory searching.
#
#          Compare with traverse_dirs.pl
#
#          See find2perl for translation of find(1).
#
#          See also stat_file_timedatestamps.pl for a way to use this.
#
# Adapted: Sat 03 Mar 2001 10:05:36 (Bob Heckel --
#            http://members.home.net/andrew-johnson/perl/archit/msg00051.html)
# Modified: Wed 23 Sep 2015 11:38:51 (Bob Heckel)
##############################################################################
use strict;
use File::Find;

my @dirs;

# Also works for PWD:  @dirs = ('.');
if ( @ARGV ) {
  @dirs = @ARGV;
} else {
  @dirs = qw{
    /mnt/nfs/home/bheckel/tmp
  };
}

# Find specific files (and their directories) only
find( sub {
        m/\.(txt|pl|tar)$/ and print "directory: $File::Find::dir\n"
                           and print "fully qualified filename:: $File::Find::name\n"
                           and print "file basename: $_\n\n";
      }, @dirs
);


# Find all dirs & subdirs
find( sub {
        -d and print "directory: $File::Find::dir\n";
      }, @dirs
);


###find( sub {
###        -d and m/1443023053_23Sep15/ and print "directory: $File::Find::dir\n";
###      }, @dirs
###);
__END__

find(\&Fnd, @dirs);

sub Fnd {
  m/\.(txt|pl|tar)$/ and print "same using coderef: $File::Find::name\n";
}


my @f;
find(\&Wanted, @dirs);
print @f;

sub Wanted {
  -f $_ and push @f, $File::Find::name;
}


# Compare with the non-recursing:
my $dir = '/home/bheckel/tmp/testing/dirtest';
opendir DH, "$dir" or die "Error: $0: $!";
my @files = grep { !/^..?$/ && !-d } map "$dir/$_", readdir DH;
print "\n\n@files\n";

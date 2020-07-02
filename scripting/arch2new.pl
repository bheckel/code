#!/usr/bin/perl
##############################################################################
#     Name: arch2new.pl
#
#  Summary: Move the newest file to another dir and reopen it to continue the
#           edit-debug-run cycle
#
#  Created: Fri 22 Dec 2006 13:28:12 (Bob Heckel)
##############################################################################
use strict;
use warnings;
use File::Find;
use File::stat;
use Data::Dumper;

##### Config #####
use constant DEBUG => 0;
###my $path = 'c:/cygwin/home/bheckel/tmp/testing'; # recursive
my $path = 'x:/SQL_Loader/New/Archive';  # recursive
my @FS;  # global - all files in $path
##################

die "moves pec from Archive to New and opens\nusage: $0 AM0952\n" if $#ARGV < 0;

sub Fnd {
  if ( $File::Find::name =~ /$ARGV[0]/o ) {
    push @FS, $File::Find::name;
  }
}
find(\&Fnd, "$path/");


sub GatherFileAttribs {
  my @filesdirs = @_;

  my @allfiles = map { my $f = stat $_;
                       $_  = (defined $f) ? { name  => $_, 
                                              mtime => $f->mtime() 
                                            } : undef 
                } grep { -f $_ } @filesdirs;

  return @allfiles;
}


sub FindNewest {
  my @allf = @_;  # do not use shift
  my $newest = 0;
  my $newestname;

  for ( @allf ) {
    if ( $_->{mtime} > $newest ) {
      $newest = $_->{mtime};
      $newestname = $_->{name};
      print $newestname . ' is '. $newest . "\n" if DEBUG;
    } else {
      print 'wtf' . $newestname . ' is '. $newest . "\n" if DEBUG;
    }
  }
  print 'hi ' . $newestname . ' is '. $newest . "\n" if DEBUG;

  return $newestname;
}


my @allf = GatherFileAttribs(@FS);
print Dumper @allf if DEBUG;
my $new = FindNewest(@allf);
$new = 'junk' if DEBUG;
# Move to \New
system('mv', '-i', "$new", "$path/..");

# Open xls for more editing
my $basenm = $1 if $new =~ m|[/\\:]+([^/\\:]+)$|;
my $p = substr($path, 0, 17);  
system('cygstart', "$p/$basenm");


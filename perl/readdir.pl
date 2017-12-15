#!/usr/bin/perl -w
##############################################################################
#     Name: readdir.pl
#
#  Summary: Demo of iterating over files in a dir, looking for textfiles then
#           printing days since last modified.
#
#  Created: Thu, 14 Sep 2000 17:13:04 (Bob Heckel)
# Modified: Fri 20 Dec 2002 15:19:09 (Bob Heckel)
##############################################################################

opendir DIRHANDLE, "." || die "Can't open dirhandle: $!\n";

# Skip dotfiles, capture basenames.
@files = grep(!/^..?$/, readdir(DIRHANDLE));
# This might be better if just want files:
# Only works if your in CWD
###my @files = grep { /^[^\.]/ && -f } readdir DIRHANDLE;
# Otherwise need this:
###my @files = grep { /^[^\.]/ && -f } map "./$_", readdir DIRHANDLE;

for ( @files ) {
  if ( $_ eq 'jump_keywords.pl' ) {
    if ( -T ) { 
      print "Days since last modi: ";
      print -M;
      print "\n";
    }
  }
}

for ( @files ) {
  if ( $_ eq 'jump_keywords.pl' ) {
    $name = (stat($_))[7];
    print $name . " bytes\n";
  }
}

closedir(DIRHANDLE);


################
my $dir = "$ENV{HOME}/tmp/testing";

opendir(DH, $dir) || die "Can't open directory $dir: $!";
# Harvest only regular files (no directories) and keep long filenames.
@nodirs = grep(-f, map("$dir/$_", readdir DH));  
rewinddir(DH);
# Harvest only directories (this doesn't work on Cygwin).
@dirs = grep(-d, readdir DH);  
closedir(DH);

print sort "@nodirs";
print sort "@dirs";

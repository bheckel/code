#!/usr/bin/perl

# Edited from the auto-generated $ find2perl . -mtime -99

# Per Perl For System Administration, don't use File::Find when
#
# 1.  If the filesystem you are traversing does not follow the normal
# semantics, you can't use it. For instance, in the bouncing laptop scenario
# which began the chapter, the Linux NTFS filesystem driver I was using had
# the strange property of not listing "." or ".." in empty directories. This
# broke File::Find badly.
# 
# 2.  If you need to change the names of the directories in the filesystem
# you are traversing while you are traversing it, File::Find gets very
# unhappy and behaves in an unpredictable way.
# 
# 3.  If you need your (Unix-based) code to chase symbolic links to
# directories, File::Find will skip them.
# 
# 4.  If you need to walk a non-native filesystem mounted on your machine
# (for example, an NFS mount of a Unix filesystem on a Win32 machine),
# File::Find will attempt to use the native operating systems's filesystem
# semantics.
#
#
# filefind.pl is a better demo
#
# Modified: Sat 06 Nov 2004 17:00:57 (Bob Heckel)

    eval 'exec /opt/sfw/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use File::Find ();

use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;

my @a;
# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, '.');
print @a;

exit;


sub wanted {
  my ($dev,$ino,$mode,$nlink,$uid,$gid);

   # print a dot for every dir so the user knows we're doing something
   ###print "." if (-d $_); 

  (($dev,$ino,$mode,$nlink,$uid,$gid) = lstat($_)) && (int(-M _) < 99)
    && push @a, "$name\n";
}


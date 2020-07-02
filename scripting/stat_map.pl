#!/usr/bin/perl -w
##############################################################################
#     Name: stat_map.pl
#
#  Summary: Use map to determine mtime and size of files.
#
#           See perldoc -f stat
#
# Adapted: Wed 29 May 2002 16:50:42 (Bob Heckel -- Teodor Zlatanov devWorks)
##############################################################################
use File::stat;
use Data::Dumper;

@files = ('/etc/passwd', '/etc/group', '/etc/nologin');

print Dumper map { 
                   $sb = stat $_;

                   $_  = (defined $sb) ? { name  => $_, 
                                           size  => $sb->size(), 
                                           mtime => $sb->mtime() 
                                         } 
                                       : undef 
                 } @files;

#!/usr/bin/perl -w
##############################################################################
#      Name: open.pl
#
#   Summary: Open and look through a file.
#
#  Created: Thu 29 Nov 2001 10:06:46 (Bob Heckel)
# Modified: Thu 09 Oct 2003 13:11:36 (Bob Heckel)
##############################################################################

# Works for small files:
open(PASSWD, '/etc/passwd' || die "Can't open: $!\n";
@the_file = <PASSWD>;
close(PASSWD);
$ok = grep /$forminput_email/, @the_file;


#################
# Put file into a variable:
open FH, $ARGV[0] or die "Error: $0: $!";
{ local $/ = undef; $contents = <FH>; }


#################
# Works for large files that can't be sucked into memory:
$i = 0;

open FH, 'junk2001.txt' or die $!;

while ( <FH> ) {  # until end of file...
  # Line is held in $_
  $i++;  # line counter
  if ( $i == 325673 ) {
    print "$i: $_\n";
    ###chomp;  # if you don't want the ending newline
  }
}

close FH;
print "Finished.\n";

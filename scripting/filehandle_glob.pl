#!/usr/bin/perl -w
##############################################################################
#     Name: filehandle_glob.pl
#
#  Summary: Demo of passing filehandles using typeglobs.  Demo of using error
#           constants instead of the normal error messages emitted when $! is
#           used in a string context.
#
#           <FH> is not the name of a filehandle, but an angle operator that
#           does a line-input operation on the handle. 
#
#  Adapted: Tue 08 May 2001 17:43:25 (Bob Heckel -- from InformIT website
#                                     Lincoln Stein)
##############################################################################

# OS independent error messages.
use Errno qw(EACCES ENOENT);

my $fh = get_fh();

print $fh 'add this to it';

sub get_fh {
  $result = open(FH, ">>/home/bheckel/junk");

  if ( !$result ) {
    if ( $! == EACCESS ) {
      warn "EACCESS you dont have permission\n";
    }
    elsif ( $! == ENOENT )  {
      warn "ENOENT file or dir not found\n";
    }
    else {
      warn "bad breakage, unknown error\n";
    }
  }

  # Print the file descriptor.
  print fileno(FH) or die "not a filehandle\n";

  # Return glob reference.  This is safer than non-reference b/c prevents
  # accidental writing to the variable and altering the symbol table.
  return \*FH;
}

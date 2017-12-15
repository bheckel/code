#!/usr/bin/perl -w
##############################################################################
#     Name: localize_filehandle.pl
#
#  Summary: Demo of not using Filehandle:IO to keep filehandles named F from
#           colliding.  Much more efficient.
#           Info also applies to dirhandles.  
#
#  Adapted: Tue 17 Dec 2002 09:06:51 (Bob Heckel -- Seven Useful Uses of 
#                                     Local)
##############################################################################

print Getfile('/home/bqh0/tmp/testing/junk');


# The only hitch is that we can't call any subroutines from this sub (must use
# local, can't use my).
sub Getfile {
  my $filename = shift;

  local *F;
  open F, "<$filename" or die "Couldn't open `$filename': $!";
  local $/ = undef;  # slurp mode
  $contents = <F>;   # return file as one single `line'
  # Not required b/c F is auto closed when the localized glob goes out of
  # scope.
  close F;           

  return $contents;
}

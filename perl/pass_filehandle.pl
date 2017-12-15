#!/usr/bin/perl -w
##############################################################################
#     Name: pass_filehandle.pl
#
#  Summary: Demo of passing a filehandle to a sub.  Recycle a filehandle.
#           Info also applies to dirhandles. 
#
#  Adapted: Tue 17 Dec 2002 09:21:26 (Bob Heckel -- Seven Useful Uses of
#                                     Local)
##############################################################################

open F, "/home/bqh0/tmp/testing/junk" or die "Error: $0: $!";

$rec = ReadRecordLoc(*F);  # use a glob
print 'local: ', $rec, "\n";
$rec = ReadRecord(*F);
print 'not local: ', $rec, "\n";
seek F, 0, 0;  # rewind filehandle to beginning
$rec = ReadRecordLoc(*F);
print 'do over: ', $rec, "\n";


# Good
sub ReadRecordLoc {
  local *FH = shift;

  my $record;
  read FH, $record, 3; # first 3 bytes

  $record =~ s/[\n\r]+//g;

  return $record;
}


# Better
sub ReadRecord {
  my $fh = shift;  # store the glob in a scalar variable

  my $record;
  read $fh, $record, 8;

  $record =~ s/[\n\r]+//g;

  return $record;
}

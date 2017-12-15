#!/usr/bin/perl -w

use strict;
use IO::File;

use constant FILE        => 'test.txt';
use constant DATA        => "this should be the first line\n";
use constant BUFFER_SIZE => '8096';

my $fh = Prepend_File(FILE, DATA, BUFFER_SIZE);

while ( my $line = <$fh> ) {
  print $line;
}

sub Prepend_File {
  my $file        = shift;
  my $data        = shift;
  my $buffer_size = shift;

  # Open a temporary and source file handle
  my $temp_fh = IO::File->new_tmpfile
    or die "Could not open a temporary file: $!";

  my $fh= IO::File->new($file, O_RDWR)
    or die "Could not open existing file ", FILE, ": $!";

  # Write the first bit of data
  $temp_fh->syswrite($data);

  # Copy all the $data from the $fh to the temp file handle
  $temp_fh->syswrite($data) while $fh->sysread($data, $buffer_size);

  $temp_fh->sysseek(0, 0);
  $fh->sysseek(0, 0);

  # Write out the new file from the temporary file handle
  $fh->syswrite($data) while $temp_fh->sysread($data, $buffer_size);

  # Could return anything here, I just chose the file handle just
  # in case we needed to use it for something
  return $fh->sysseek(0, 0) && $fh;
}

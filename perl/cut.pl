#!/usr/bin/perl -w
##############################################################################
#     Name: cut.pl (s/b symlinked as supercut)
#
#  Summary: Extracts column(s) of text from a file and delimits the output,
#           space-padding if needed.
#           Allows overlapping ranges so we can't use pack().
#
#  Adapted: Fri 05 Dec 2003 12:27:44 (Bob Heckel --
#                             file:///C:/bookshelf_perl/advprog/ch05_05.htm)
##############################################################################

use constant USAGEMSG => <<USAGE;
Usage: supercut [-s<n>] [-d] col-range1, col-range2, files ...
       where col-range is specified as col1-col2 (column 1 through column2)
       or col1+n, where n is the number of columns.  Use -d for debugging.
       E.g.:
       cut.pl 5-11 10-15 test.dat
USAGE

die USAGEMSG unless $ARGV[0];

$size = 0;          # 0 => line-oriented input, else fixed format.
@files = ();        # list of files
$open_new_file = 1; # force get_next_line() to open the first file
$debugging = 0;     # enable with -d commmand line flag
$col = ''; 
$code = '';
generate_part1();  
generate_part2();
generate_part3();
col();              # sub col has now been generated so call it now
exit 0;


#------------------------------------------------------------------
sub generate_part1 {
  # Generate the initial invariant code of sub col()
  $code  = 'sub col { my $tmp;';           # note the single quotes
  $code .= 'while ( 1 ) { $s = get_next_line(); $col = "";';
  # TODO make this a param to be optionally passed in
  $delimiter = '|';
}

#------------------------------------------------------------------
# Process arguments.
sub generate_part2 {
  my ($col1, $col2);

  foreach $arg ( @ARGV ) {
    if ( ($col1, $col2) = ($arg =~ /^(\d+)-(\d+)/) ) {
      $col1--;  # make it 0 based
      $offset = $col2 - $col1;
      add_range($col1, $offset);
    } elsif ( ($col1, $offset) = ($arg =~ /^(\d+)\+(\d+)/) ) {
      $col1--;
      add_range($col1, $offset);
    } elsif ( $size = ($arg =~ /-s(\d+)/) ) {
      # noop
    } elsif ( $arg =~ /^-d/ ) {
      $debugging = 1;
    } else {
      # Then it must be a file name.
      push @files, $arg;
    }
  }
}

#------------------------------------------------------------------
sub generate_part3 {
  $code .= 'print $col, "\n";} }';

  print $code if $debugging;  # -d flag enables debugging.
  eval $code;
  if ( $@ ) {
    die "Error ...........\n $@\n $code \n";
  }
}

#------------------------------------------------------------------
sub add_range { 
  my ($col1, $numChars) = @_;

  # substr() complains (under -w) if we look past the end of a string
  # To prevent this, pad the string with spaces if necessary.
  $code .= "\$s .= ' ' x ($col1 + $numChars - length(\$s))";
  $code .= "    if (length(\$s) < ($col1+$numChars));";
  $code .= "\$tmp = substr(\$s, $col1, $numChars);";
  $code .= '$tmp .= " " x (' . $numChars .  ' - length($tmp));';
  $code .= "\$col .= '$delimiter' . \$tmp; ";
}

#------------------------------------------------------------------
sub get_next_line {
  my($buf);

NEXTFILE:
  if ( $open_new_file ) {
    $file = shift @files || exit 0;
    open F, $file || die "$@\n";
    $open_new_file = 0;
  }
  if ( $size ) {
    read(F, $buf, $size);
  } else {
    $buf = <F>;
  }
  if ( ! $buf ) {
    close F;
    $open_new_file = 1;
    goto NEXTFILE;
  }
  chomp $buf;

  # Convert tabs to spaces (assume tab stop width == 8)

  # Expand leading tabs first--the common case.  e option is to remove tabs.
  $buf =~ s/^(\t+)/' ' x (8 * length($1))/e;

  # Now look for nested tabs. Have to expand them one at a time - hence
  # the while loop. In each iteration, a tab is replaced by the number of
  # spaces left till the next tab-stop. The loop exits when there are
  # no more tabs left
  1 while ($buf =~ s/\t/' ' x (8 - length($`)%8)/e);

  $buf;
}


__END__
asdg dl1j111sdfl  sdflkj lklkkd wooweri
ASDG DL2J111SDFL  SDFLKJ LKLKKD WOOWERI
asdg dl3j11xsdfz  sdflkj lklkkd wooweri

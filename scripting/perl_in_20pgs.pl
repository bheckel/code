#! /usr/bin/perl -w
##############################################################################
# Example perl prototype file - extract H1,H2 or H3 headers from HTML files
# Run via:
#   perl this-perl-script.pl [-o outputfile] input-file(s)
# E.g.
#   perl proto-getH1.pl -o headers *.html
#   perl proto-getH1.pl -o output.txt homepage.htm
#
# Created: Russell Quong         2/19/98
# Adapted: Wed, 03 Nov 1999 09:16:58 (Bob Heckel)
##############################################################################

require 5.003;                # need this version of Perl or newer
use English;                  # use English names, not cryptic ones
###use FileHandle;               # use FileHandles instead of open(),close()
use Carp;                     # get standard error / warning messages
###use strict;                   # force disciplined use of variables

my $author = "Russell W. Quong";
my $version = "Version 1.0";
my $reldate = "Jan 1998";
my $lineno = 0;                # variable, current line number
###my($OUT) = \*STDOUT;            # default output file stream, stdout
my @headerArr = ();            # array of HTML headers

# Print out a non-crucial FYI messages.
# By making fyi() a function, we enable/disable debugging messages easily.
sub fyi($) {
  my $str = @_;
  print "$str\n";
}

sub main () {
  fyi("\nPerl script = $PROGRAM_NAME, $version, $author, $reldate.\n");
  handle_flags();
  # Handle remaining command line args, namely the input files
  if (@ARGV == 0) {
    handle_file('-');
  } else {
      my $i;
      foreach $i (@ARGV) {
        handle_file($i);
      }
  }
  postProcess();              # Additional processing after reading input.
}

# Handle all the arguments, in the @ARGV array.
# We assume flags begin with a '-' (dash or minus sign).
sub handle_flags () {
  my($a, $oname) = (undef, undef);
  foreach $a (@ARGV) {
    if ($a =~ /^-o/) {
        shift @ARGV;                # discard ARGV[0] = the -o flag
        $oname = $ARGV[0];          # get arg after -o
        shift @ARGV;                # discard ARGV[0] = output file na me
        ###$OUT = new FileHandle "> $oname";
        ###if (! defined($OUT) ) {
        if (! defined(OUT) ) {
            croak "Unable to open output file: $oname.";
            exit(1);
        }
    } else {
        last;                       # Break out of this loop
    }
  }
}

# handle_file (FILENAME);
# Open a file handle or input stream for the file named FILENAME.
# If FILENAME == '-' use stdin instead.
sub handle_file ($) {
  my($infile) = @_;
  ###fyi(" handle_file($infile)");
  if ($infile eq "-") {
      ###read_file(\*STDIN, "[stdin]");  # \*STDIN=input stream for STDIN.
      read_file(<STDIN>);  # \*STDIN=input stream for STDIN.
  } else {
      ###my($IN) = new FileHandle "$infile";
      open(IN, $infile);
      ###if (! defined($IN)) {
      if (! defined(IN)) {
          fyi("Can't open spec file $infile: $!\n");
          return;
      }
      read_file(IN, "$infile");      # $IN = file handle for $infile
      ###$IN->close();           # done, close the file.
      close(IN);
  }
}

# read_file (INPUT_STREAM, filename);
sub read_file ($$) {
  my($IN, $filename) = @_;
  my($line, $from) = ("", "");
  $lineno = 0;                        # reset line number for this file
  ###while ( defined($line = <$IN>) ) {
  while ( defined($line = <IN>) ) {
    $lineno++;
    chomp($line);                   # strip off trailing '\n' (newline)
    do_line($line, $lineno, $filename);
  }
}

# do_line(line of text data, line number, filename);
# Process a line of text.
sub do_line ($$$) {
  my($line, $lineno, $filename) = @_;
  my($heading, $htype) = undef;
  # search for a <Hx> .... </Hx>  line, save the .... in $header.
  # where Hx = H1, H2 or H3.
  if ( $line =~ m:(<H[123]>)(.*)</H[123]>:i ) {
      $htype = $1;            # either H1, H2, or H3
      $heading = $2;          # text matched in the parethesis in the re gex
      fyi("FYI: $filename, $lineno: Found ($heading)");
      ###print $OUT "$filename, $lineno: $heading\n";
      print "$filename, $lineno: $heading\n";

        # we'll also save the all the headers in an array, headerArr
      push(@headerArr, "$heading ($filename, $lineno)");
  }
}

# Print out headers sorted alphabetically
sub postProcess() {
  my(@sorted) = sort { $a cmp $b } @headerArr;   # example using sort
  ###print $OUT "\n--- SORTED HEADERS ---\n";
  print "\n--- SORTED HEADERS ---\n";
  my $h;
  foreach $h (@sorted) {
      ###print $OUT "$h\n";
      print "$h\n";
  }
  my $now = localtime();
  print "\nGenerated $now.\n"
}

# Start executing at main()
main();
0;              # return 0 (no error from this script)


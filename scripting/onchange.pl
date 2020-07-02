#!/usr/bin/perl -w
##############################################################################
#    Name: onchange.pl
#
# Summary: Detect change in a file and do command(s) in response.
#
#          TODO allow more than one file to change before running cmd
#
#          TODO allow sasrun to work (needs stdout for vi)
#
#          See simpler (better?) execOnChange.sh
#
# Created: Mon, 02 Oct 2000 08:32:40 (Bob Heckel -- portions from adapted from
#                                     Jeff Haemer's atchange)
# Modified: Fri 21 Mar 2003 08:36:41 (Bob Heckel)
##############################################################################

$0 =~ s(.*/)();
$usage =<<"EOT";
Monitor a file for changes, perform action(s) if change is detected.
 Usage: $0 filename cmd  
   E.g. onchange test.pl 'perl test.pl'
   E.g. onchange test.pl 'perl test.pl; date'
   E.g. onchange config.dat 'diff config.dat config.dat.bak'
 Exit with a Ctrl-C
EOT

unless ( @ARGV ) { print $usage; exit 0; }
# Must start this script from same dir as file you're monitoring.
unless ( -e $ARGV[0] ) { print "\nFile does not exist!\n\n.  $usage"; exit 0; }

if ( $ARGV[0] =~ /-+h*/ ) { print $usage; exit(0) };

$shell = $ENV{"SHELL"} ? $ENV{"SHELL"} : "/bin/bash";

open(SHELL, "|$shell") || die "Can't pipe to $shell: $!";
select(SHELL); 
$| = 1;

if ( @ARGV > 1 ) {                         # It's a file and a command
   $file = shift;                          # Peel off the filename
   $cmd{$file} = join(" ", @ARGV) . "\n";  # and the command
   $old{$file} = (stat($file))[9];         # Mod time
} else {                                   # It's a program
  open(PGM, shift) || die "Can't open $_: $!";
  $/ = "";                                 # Paragraph mode
  while ( <PGM> ) {                        # First read the program
    s/#.*\n/\n/g;
    ($file, $cmd) = /(\S*)\s+([^\000]+)/;
    $cmd{$file} = $cmd;
    unless ($file) { print $cmd{$file}; next; }
    if ( $file && ! $cmd{$file} ) { warn "odd line"; next; };
    $old{$file} = (stat($file))[9];         # Mod time
  }
}

while (1) {
  sleep(1);
  select(undef, undef, undef, 0.25);       # Wait a quarter second, then
  foreach ( keys %cmd ) {                  # Rip through the whole list
    atchange($_);
  }
  # Ctrl-C is the only way out; make it graceful.
  $SIG{INT} = \&catch_zap;
}
close(SHELL);


# If $file has changed, do $cmd{$file}
sub atchange {    
  my($file) = @_;
  my($new);

  $new = (stat($file))[9];
  return 0 if ($old{$file} == $new);
  while ( 1 ) {                             # wait until it stops changing
    $old{$file} = $new;
    sleep 1;
    $new = (stat($file))[9];
    if ($old{$file} == $new) {
      warn "\n           $ENV{fg_yellow}=-=DEBUG=-=", 
           scalar(localtime),
           "=-=DEBUG=-= $ENV{normal}\n";
      print $cmd{$file};
      return 1;
    }
  }
}


sub catch_zap {
  my $signame = shift;

  exit(0);
}

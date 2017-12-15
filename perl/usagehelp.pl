# Modified: Fri 16 Dec 2016 08:45:18 (Bob Heckel)

# 6 is probably best for a usage msg that is longer than 1 line.

##############################################################################
# 1.
# $#ARGV is -1 with no params, 0 with one param, 1 with two params...
# One, and only one, parameter must be passed:
if ( $#ARGV != 0 ) {
  print STDERR "Usage: $0 myparm\n";
  exit -1;
}
# 1st arg is 0 so this would scream if no args passed
die "Usage: $0 myparm\n" if $#ARGV < 0;

# or:
die "Usage: mypgm onething twothing [...]\n" unless $ARGV[0];

# or if don't want any parms:
Usage() if $#ARGV != -1;


##############################################################################
# 2.
# User is asking for help.
if ( @ARGV && $ARGV[0] =~ /-+h.*/ ) {
  print STDERR "Usage: $0 [-h --help]\n";
  exit(__LINE__);
}
# User may ask for help but if not, some parameter must be passed:
if ( !@ARGV || $ARGV[0] =~ /-+h.*/ ) {
  print STDERR "Usage: $0 2 foo\nGenerates file 2 megs in size named foo.\n";
  exit(__LINE__);
}


##############################################################################
# 3.
# Usage as a sub.  #4 IS BETTER.
Usage($0, '') if ( $ARGV[0] =~ /-+h.*/ );
my $filename = $ARGV[0] || Usage($0, 'No textfile provided');
open(FH, $filename) || Usage($0, $!);


sub Usage {
  my $errfile  = $_[0];
  my $errmsg   = $_[1];

  if ( $errmsg ) {
    print STDERR "$errmsg.  Exiting.\n";
  } else {
    print<<EOT
This application parses a Fuji fiducial ...
EOT
  }
    print "Usage: $errfile [-h --help] TEXTFILE_TO_PROCESS\n";
    exit __LINE__ ;
}

##############################################################################
# 4.
# Usage as a sub (better).
Usage() unless ( $#ARGV > 1 );
Usage() if ( $ARGV[0] =~ /-+h.*/);

sub Usage {
  my $filename = $1 if $0 =~ m|[/\\:]+([^/\\:]+)$|;
  print <<"EOT";
Usage: $filename DIRECTORY1 DIRECTORY2 [DIRECTORY3]
Synopsis:
  Copies the most recent version of files from either DIRECTORY1
  or DIRECTORY2 into DIRECTORY3 (defaults to 'mostrecent' in your
  current working directory if you do not specify DIRECTORY3).
EOT
  exit(__LINE__);
}


##############################################################################
# 5.
# Long usage message (poor man's pager)
sub Usage {
  print STDERR <<EOD;

GRGET downloads test program files from the server for a particular PEC code.
If no test program release is specified, it gets the current default release.

EOD

print STDERR "Press enter to continue . . ."; <STDIN>;
    


##############################################################################
# 6.
# Using a constant, demand two parameters separated by a colon:

use constant USAGEMSG => <<'USAGE';
Usage: latebf19 STATE YEAR
       e.g. latebf19 nj 02
USAGE

die USAGEMSG unless my ($state, $year) = $ARGV[0] =~ /(.+):(.+)/;
###die USAGEMSG $ARGV[0];



##############################################################################
# 7.
# getopts

use Getopt::Std;

getopt('p:c');
die "Usage: $0 [-p <filename>|-c <filename>]\n" unless ( $opt_p or $opt_c );


##############################################################################
# 8.
# Must pass a parameter
die "usage: foo [abc]\n" if ! $ARGV[0];


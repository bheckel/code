##############################################################################
#     Name: Load_mysql_db_util.pm
#
#  Summary: Utility functions used by load_mysql_db_indxls.pl and 
#           load_mysql_db_occxls.pl
#
#  Created: Fri 13 Dec 2002 15:21:05 (Bob Heckel)
##############################################################################
package Load_mysql_db_util;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(Warn Results);
use strict;


sub Warn {
  my $f = shift;

  print "Make sure \n", $f, "\nhas been uppercased and any " .
        "header line(s) deleted.  Continue? ";
  <STDIN> ne "n\n" ? print "ok\n" : die "Exiting\n";

  return 0;
}


sub Results {
  my $n = shift;
  my $t = shift;
  my $d = shift;

  print "Finished.  $n records inserted into table " . $t .
        " on database " . $d . "\n";

  return 0;
}


# Determine max width of input data.
###sub MaxWidths {
###  my $f = shift;
###  my @fields = @_;
###
###  my %h = ();
###  for ( @fields ) {
###    $h{$_} = 0;
###  }
###
###  open INPUTFILE, $f or die "Error: $0: $!";
###  while ( <INPUTFILE> ) {
###    chomp $_;
###    my @tmp = split '\t';
###    for ( my $i=0; $i<@tmp; $i++ ) {
###      while ( (my $key, my $val) = each %h ) {
###        $h{$key} = length($tmp[$i]) if length($tmp[$i]) > $h{$key};
###      }
###    }
###  }
###  ###while ( (my $key, my $val) = each %h ) {
###  ###print "DEBUG: max $key is $val\n";
###  ###}
###  close INPUTFILE;
###
###  ###return %h;
###  return (50, 50, 50, 50);
###}


1;

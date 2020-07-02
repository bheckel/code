#!/usr/bin/perl
##############################################################################
#     Name: rma_parser.pl
#
#  Summary: Parse several poorly formatted emails from Robert Parrish to pipe
#           delimited textfile.
#
#  Created: Tue 06 Nov 2001 10:48:15 (Bob Heckel)
##############################################################################

# Header line.
print "Error code|Check record for Warehouse|Qty|Error desc|Item\n";

###$emailfile = 'email_test_woIS.txt';
$emailfile = 'email_robert_woIS.txt';
###open(EMAIL, "email_robert.txt") || die "$0: can't open file: $!\n";
###open(EMAIL, "email_robert_woIS.txt") || die "$0: can't open file: $!\n";
open(EMAIL, $emailfile) || die "$0: can't open file: $!\n";

$i         = 0;
%pipedelim = ();

# Doing two passes over the input file b/c "Error desc" and "Item" may span
# multiple lines.
while ( <EMAIL> ) {
  next if /^$/;

  if ( /Error code : (\w+) / ) {
    $i++;
    # There is no discreet primary key to use so we're using a numerical
    # series starting with 1.
    $pipedelim{$i} .= "$1|";
  }

  if ( /Check record for Warehouse: (\w+),/ ) {
    $pipedelim{$i} .= "$1|";
  }

  ###if ( /Item: (\w+),/ ) {
    ###print "got Item $1\n";
    ###$pipedelim{$i} .= "$1|";
  ###}

  if ( /Quantity: (-?\d+\.?\d+)/ ) {
    $pipedelim{$i} .= "$1|";
  }
}

close(EMAIL);  # first time, to prepare for re-open

# Error Desc. and Item fields may span multiple lines, we can't use the simple
# method above to capture it.
{ 
  # Prepare Slurpee.
  local $/ = 'Technical Reason:';  # my unique "line" separator
  $i = 0;

  open(EMAIL, $emailfile) || die "$0: can't open file: $!\n";

  while ( <EMAIL> ) {
    next if /^$/;

    next unless $_ =~ /Error Desc.: (.*?)Reason2/s;
    $i++;
    $description = $1;
    # Remove linefeed, if any, leaving a space for line continuations.
    $description =~ s/(\012)+/ /;  # TODO why must run twice?  
    $description =~ s/(\012)+//;  
    unless ( $i == 0 ) { $pipedelim{$i} .= "$description|"; }

    $_ =~ /Item: (.*?)Lot:/s;
    $item = $1;
    $item =~ s/(\012)+//;  
    unless ( $i == 0 ) { $pipedelim{$i} .= "$item\n"; }
    ###unless ( $item =~ /\n$/ ) { $item .= "\n"; }  # make sure there's only a trailing linefeed

  }

  close(EMAIL);

  # To STDOUT.
  while ( (my $key, my $val) = each(%pipedelim) ) { 
    ###print "$key=$val" if $i > 0;
    print "$val" if $i > 0;
  }
}

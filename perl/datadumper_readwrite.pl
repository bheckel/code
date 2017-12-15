#!/usr/bin/perl -w
##############################################################################
#     Name: datadumper_readwrite.pl
#
#  Summary: Save Perl object state (in this case, array) to disk.
#
#  Created: Thu 29 Apr 2004 16:02:44 (Bob Heckel)
# Modified: Tue 20 Mar 2007 12:27:07 (Bob Heckel)
##############################################################################
use Data::Dumper;

# 1st run to store:
open FH, '>junkoutreasonlist';
print FH Data::Dumper->Dump([ \@reasonList ], [ *reasonList ]);
###print FH Data::Dumper->Dump([ \%areaForReason ], [ *areaForReason ]);

# 2nd run to repopulate:
open FH, 'junkoutreasonlist' or die "$!";
{local $/ = undef; $mystate = <FH>;}
$r = eval(Dumper($mystate));
print Dumper $r;



__END__
if ( -f 'junkstate' ) {
  # Read a previously saved array from disk, if available.
  open FH, 'junkstate' or die "Error: $0: $!";
  {local $/ = undef; $mystate = <FH>;}
  # Recover a reference to the saved array on disk.
  $ra = eval $mystate;
  @data = @$ra;
} else { 
  @data = ("one","two","three","four","five");
}

# Test by changing an element.
$data[0] = localtime;
###print @data;

# Write the array, after changes, to disk.
open FH2, '>junkstate' or die "Error: $0: $!";
print FH2 Data::Dumper->Dump( [\@data ], [ *data ]);

###print @data;

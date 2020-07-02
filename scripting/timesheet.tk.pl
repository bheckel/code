#!/usr/bin/perl -w
##############################################################################
#     Name: timesheet.tk.pl
#
#  Summary: Track hours worked in a week.
#
#           Tk Demos:
#           /usr/lib/perl5/site_perl/5.6.1/cygwin-multi/Tk/demos/widget_lib
#
#  Created: Wed 17 Jul 2002 10:52:20 (Bob Heckel)
# Modified: Sat 20 Jul 2002 09:47:44 (Bob Heckel)
##############################################################################
use strict;
use Tk;

# Read tab delimited input file into an array of arrays.
open FILEREAD, "timesheet.dat" || die "$0: can't open file: $!\n";
my @clockhrs = ();  # global!
while ( <FILEREAD> ) {
  chomp;  # the newline at end of each week's hours
  push(@clockhrs, [split '\t']);
}
close FILEREAD;


my $mw = MainWindow->new;
$mw->title('Timesheet');
$mw->Label(-text => 'Timesheet',
          )->pack;
# Make numbers change on any key release.
$mw->bind('Tk::Entry', '<KeyRelease>' => sub{do_calc()});

# Packing list.  Make each day have its own row.
my @pl = qw/-side left/;

# TODO create a loop for this mess using this format
###for my $i ( 0 .. $#clockhrs ) {
###  # handle 0 [0][1]
###  for my $j ( 0 .. $#clockhrs ) {
###    # handle 1 [0][1]
###    $txtbox$i = $sunframe->Entry(-width => 5, 
###                                 -textvariable => \$clockhrs[$i][$j]
###                                )->pack(@pl);
###  }
###} 
my $sunframe = $mw->Frame()->pack();
$sunframe->Label(-text => 'Sunday',
                 -width => 9,
                )->pack(@pl);
my $suntot = $clockhrs[0][1] - $clockhrs[0][0] + $clockhrs[0][3] - 
                                                            $clockhrs[0][2];
$sunframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[0][0],
                )->pack(@pl);
$sunframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[0][1],
                )->pack(@pl);
$sunframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[0][2],
                )->pack(@pl);
$sunframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[0][3],
                )->pack(@pl);
$sunframe->Label(-width => 6,
                 -textvariable => \$suntot
                )->pack(@pl);

my $monframe = $mw->Frame()->pack();
$monframe->Label(-text => 'Monday',
                 -width => 9,
                )->pack(@pl);
my $montot = $clockhrs[1][1] - $clockhrs[1][0] + $clockhrs[1][3] - 
                                                            $clockhrs[1][2];
$monframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[1][0],
                )->pack(@pl);
$monframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[1][1],
                )->pack(@pl);
$monframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[1][2],
                )->pack(@pl);
$monframe->Entry(-width => 5,
                 -textvariable => \$clockhrs[1][3],
                )->pack(@pl);
$monframe->Label(-width => 6,
                 -textvariable => \$montot
                )->pack(@pl);

my $totframe = $mw->Frame()->pack();
my $grandtot = $suntot + $montot;
$totframe->Label(-width => 6,
                 -textvariable => \$grandtot,
                )->pack(@pl);

$mw->Button(-text => 'Save',
            -command => sub{do_save()}
            )->pack;

MainLoop;


sub do_save {
  # Overwrite old with changed hours.
  open FILEWRITE, ">timesheet.dat" || die "$0: can't open file: $!\n";
  # Write changes.
  for my $i ( 0 .. $#clockhrs ) {
    my $aref = $clockhrs[$i];
    my $n = @$aref - 1;
    for my $j ( 0 .. $n ) {
      print FILEWRITE "$clockhrs[$i][$j]\t";
    }
    print FILEWRITE "\n"; # replace the newline between weeks (chomped earlier)
  }
  close FILEWRITE;
}


sub do_calc {
  # Refresh the total.
  $suntot = $clockhrs[0][1] - $clockhrs[0][0] + $clockhrs[0][3] - 
                                                           $clockhrs[0][2];
  $montot = $clockhrs[1][1] - $clockhrs[1][0] + $clockhrs[1][3] - 
                                                           $clockhrs[1][2];
  $grandtot = $suntot + $montot;
}


# Sample data:
# 8	11	12	16	9	12	13	17	2	3	4	5	0	1	2	3	4	5	6
# 6	11	10	16	9	5	13	17	2	3	4	5	3	1	2	3	9	5	6

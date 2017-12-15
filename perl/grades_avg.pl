#!/usr/bin/perl -w
##############################################################################
#    Name:
#
# Summary: 1:An Overview of Perl/An Average Example
#
# Adapted: Fri, 04 Aug 2000 10:59:38 (Bob Heckel -- from Programming Perl v3)
##############################################################################

# Sample data in grades.dat:
# bob 75
# bob 95
# xman 30
# xman 35
# ayn 38
# ayn 39
# ayn 40

open(GRADES, 'grades.dat') or die "Can't open $0: $!\n";
while ($line = <GRADES>) {
  ($student, $grade) = split(" ", $line);
  $grades{$student} .= $grade . " ";
}

foreach $student (sort keys %grades) {
  $scores = 0;
  $total = 0;    
  @grades = split(" ", $grades{$student});
  foreach $grade (@grades) {
      $total += $grade;
      $scores++;
  }
  $average = $total / $scores;
  print "$student: $grades{$student}\tAverage: $average\n";
}

# Sample output:
# ayn: 38 39 40   Average: 39
# bob: 75 95      Average: 85
# xman: 30 35     Average: 32.5

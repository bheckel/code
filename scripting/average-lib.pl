
sub Avg {
  $ra = shift;
  $cnt = 0;
  $tot = 0;

  foreach $e ( @$ra ) {
    $tot += $e;
    $cnt++;
  }

  $avg = $tot / $cnt;
  print $avg;
}


1;

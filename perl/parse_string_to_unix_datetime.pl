
use Time::Local;

sub parseStringToUnix { 
  my($s) = @_;
  my($year, $month, $day, $hour, $minute, $second);

  if($s =~ m{^\s*(\d{1,4})\W*0*(\d{1,2})\W*0*(\d{1,2})\W*0*
                 (\d{0,2})\W*0*(\d{0,2})\W*0*(\d{0,2})}x) {
    $year = $1;  $month = $2;   $day = $3;
    $hour = $4;  $minute = $5;  $second = $6;
    $hour |= 0;  $minute |= 0;  $second |= 0;  # defaults.
    $year = ($year<100 ? ($year<70 ? 2000+$year : 1900+$year) : $year);

    return timelocal($second,$minute,$hour,$day,$month-1,$year);  
  }
  return -1;
}

###print parseStringToUnix('2013-10-02');
print parseStringToUnix('2013-10-02 23:59:59');

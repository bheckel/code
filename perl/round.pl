# For possible negative numbers.
sub round {
  use POSIX;
  $arg = $_[0];

  if ( $arg > 0.0 ) {
    $arg = floor($arg + 0.5);
  } elsif ( $arg < 0.0 ) {
    $arg = ceiling($arg - 0.5);
  } else {
    $arg = 0.0;
  }

  return $arg;
}


# For positive numbers only.
sub round {
  $arg = $_[0];

  if ( $arg > 0.0 ) {
    $arg = int($arg + 0.5);
  } else { 
    $arg = 0.0;
  }
  
  return $arg;
}

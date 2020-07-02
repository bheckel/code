sub debug {
  my ($package, $filename, $line, $subroutine, $hasargs, $wantarray) = 
                                                                    caller();
  my $thisone = "Greetings from debug()\n" .
         "pkg--->$package\nfname--->$filename\nline--->" .
         "$line\nsub--->$subroutine\nhasargs--->$hasargs\nwantarray--->" .
         "$wantarray\n\n";

  my ($package, $filename, $line, $subroutine, $hasargs, $wantarray) = 
                                                                    caller(1);
  my $callingone = "calling_pkg--->$package\ncalling_fname--->$filename\n" .
                   "calling_line--->$line\nsub--->$subroutine\nhasargs--->" .
                   "$hasargs\nwantarray--->$wantarray";
  
  return $thisone . $callingone;
}

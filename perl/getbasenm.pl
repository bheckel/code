# Capture the lowest dir from the fully qualified path.
sub getbasenm {
  my $in = $_[0];
  # Clean up the path to not confuse following code with the trailing / 
  $in =~ s/\/$//g;
  # Capture position number of char preceeding / then add one to land on the
  # slash specifically.  This is where substr will start extracting to the
  # end.
  $position = rindex($in, "/") + 1;
  $basenm = substr($in, $position);
  # Space-in-path names may have trailing " to be removed if w95.
  $basenm =~ s/\"$//;
  # Put these shorties into a new array.
  ###@shortnames = ($basenm, @shortnames);
  return $basenm;
}

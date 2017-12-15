# Adapted: Thu, 21 Dec 2000 10:27:39 (Bob Heckel from Mark Hewett's grlib.pl)

$FS = '/';
print parseFileSpec('%NAME%', 'grls.bat');
print "\n";
print parseFileSpec('%TAIL%', '/foo/grls.bat');

sub parseFileSpec {
  # Split a Unix path into its component parts.  Return those components
  # as directed by a format string containing placeholders from the 
  # following list: %HEAD% %TAIL% %NAME% %TYPE%

  local($format,$path) = @_;

  @fields = split(/\//,$path);
  $tail = pop(@fields);
  $head = join($FS,@fields);
  ($name,$type) = split(/\./,$tail);

  $fs = $format;
  $fs =~ s/%HEAD%/$head/g;
  $fs =~ s/%TAIL%/$tail/g;
  $fs =~ s/%NAME%/$name/g;
  $fs =~ s/%TYPE%/$type/g;

  return $fs;
}

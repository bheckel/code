#!/usr/bin/perl -w

print unquote('""foo bar"');

sub unquote {
  # Extract and return quoted string contents from input string
  my($str) = @_;

  ($result) = ($str=~ /^"(.*)"$/);
  unless ( $result ) { $result = $str; }

  return $result;
}


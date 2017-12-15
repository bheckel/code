# http://www.unix.org.ua/orelly/perl/advprog/ch06_08.htm

package DUMPVAR;

sub dumpvar {
  my ($packageName) = @_;

  local (*alias);             # a local typeglob

  # We want to get access to the stash corresponding to the package
  # name
  *stash = *{"${packageName}::"};  # Now %stash is the symbol table
  $, = " ";                        # Output separator for print

  # Iterate through the symbol table, which contains glob values
  # indexed by symbol names.
  while (($varName, $globValue) = each %stash) {
    print "$varName ============================= \n";
    *alias = $globValue;
    if (defined ($alias)) {
      print "\t \$$varName $alias \n";
    } 
    if (defined (@alias)) {
      print "\t \@$varName @alias \n";
    } 
    if (defined (%alias)) {
      print "\t \%$varName ",%alias," \n";
    }
  }
}

1


__END__
#!/usr/bin/perl

use Dumpvar;

package XX;
$x = 10;
@y = (1,3,4);
%z = (1,2,3,4, 5, 6);
$z = 300;
DUMPVAR::dumpvar("XX");

#!/usr/bin/perl -w
##############################################################################
#    Name: closure.pl
#
# Summary: Demo of using closures.
#
#          A subroutine that refers to (and preserves) one or more lexical
#          variables declared outside the subroutine itself, even after they
#          become inaccessible anywhere else.  After a block ends, the
#          subroutine is the only way to still access the variable(s).
#
# Adapted: Thu 15 Mar 2001 14:04:51 (Bob Heckel p. 56 OO Perl and 
#                                               p. 260 Programming Perl v3)
# Modified: Wed 06 Apr 2011 11:04:00 (Bob Heckel)
##############################################################################

sub make_iterator {
  my @items = @_;
  my $count = 0;

  # This anonymous sub closes over a unique lexical environment...
  return sub {
    # ...so lexical variables count and items persist across calls
    return if $count==@items;
    return $items[$count++];
  }
}

my $cousins=make_iterator(qw(Rick Alex Kaycee Eric Corey));
###print $cousins->() for 1..5;
###print "\n";

my $aunts=make_iterator(qw(Carole Phyllis Wendy));

print $aunts->();
print $cousins->();
print $aunts->();
print $cousins->();


__END__
print "Example 1---------------------\n";

{
  my $name = 'Damian Cox';

  sub Print_my_name { print $name; }     # <---closure
}

# $name s/b blank due to scoping..
print "This is my name: ---- $name ----\n";

# But this works.
Print_my_name();



print "Example 2---------------------\n";

{
  my $dromedary = 'camel';

  $dromedaryref = \$dromedary;
}

print "$dromedary not available\n";
print "But $$dromedaryref is.\n";


print "xxxxxxxxxx\n";


{
  my $dromedary = 'perlcamel';

  $dromedaryref = sub { return $dromedary };
}

print "$dromedary not available\n";
$x = &$dromedaryref;
print "But $x is.\n";



print "Example 3---------------------\n";

sub Newprint {
	my $x = shift;
	return sub { my $y = shift; print "$x, $y!\n"; };
}

$h = Newprint("Howdy");
$g = Newprint("Greetings");

# Time passes...

# $x continues to refer to the value passed into Newprint() despite "my $x"
# having gone out of scope by the time the anonymous subroutine runs. That's
# what a closure is all about.
&$h("world");
&$g("earthlings");  

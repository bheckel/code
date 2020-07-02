#!/usr/bin/perl -w
##############################################################################
#     Name: date_string_range.pl
#
#  Summary: List days with a range, wrapping around if necessary.
#
# Adapted: Wed 10 Oct 2001 17:37:59 (Bob Heckel -- Unix Review Col 39 8/2001)
##############################################################################

# If we put @day_names inside the subroutine, it'll get initialized every
# time, at a slight speed penalty. However, if we put it outside the
# subroutine, it needs to get executed before the initialization occurs.
# Fortunately, we can create "static local" variables using a BEGIN:
#
# The BEGIN block causes the code to be executed at compile time, initializing
# the value of @day_names before any other "normal" code is executed. And the
# variable is local to the block, so it won't be seen by any other part of the
# program, just the subroutine inside the BEGIN block.
BEGIN {
  my @day_names = qw(Sun Mon Tue Wed Thu Fri Sat);
  my %mapping; @mapping{@day_names} = 0..$#day_names;

  sub day_string_range {
    die "too few args: @_" if @_ < 2;
    die "too many args: @_" if @_ > 2;
    my ($start,$end) = @_;

    foreach ($start, $end) {
      exists $mapping{$_} or die "no such name: $_";
      $_ = $mapping{$_};
    }

    my @return;
    while (1) {
      push @return, $day_names[$start];
      last if $start == $end;
      ($start += 1) %= 7;
    }
    return join ",", @return;
  }
}

print day_string_range('Mon', 'Wed');
print "\n";
print day_string_range('Wed', 'Sun');  # wrap

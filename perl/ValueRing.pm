# Used by ~/code/perl/tie.pl to demonstrate tied scalars.
package ValueRing;

# Constructor for scalar ties.
sub TIESCALAR {
  my ($class, @values) = @_;

  bless  \@values, $class;

  return \@values;
} 

# Intercepts read accesses.
sub FETCH {
  my $self = shift;

  push @$self, shift(@$self);

  return $self->[-1];
} 

# Intercepts write accesses.
sub STORE {
  my ($self, $value) = @_;

  unshift @$self, $value;

  return $value;
} 


1;

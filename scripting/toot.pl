#!/usr/bin/perl -w
##############################################################################
#    Name: toot.pl
#
# Summary: Code from perltoot.  Object oriented.  Uses hash to hold data
#          fields.
#
# Adapted: Thu, 25 Jan 2001 11:13:13 (Bob Heckel -- Christiansen)
##############################################################################

###use Carp;

my $Census = 0;
my $Debugging = 1;

package Person;
###use strict;

# The object constructor.
sub new {
  my $proto = shift;

  my $class        = ref($proto) || $proto;
  # Get a reference to an empty anonymous hash.
  my $self         = {};
  ###$Census++;
  $self->{NAME}    = undef;
  $self->{AGE}     = undef;
  $self->{PEERS}   = [];
  # Private data.
  $self->{_CENSUS} = \$Census;

  ++${$self->{_CENSUS}};
  # Bless $self object into the current pkg.
  ###return bless($self);
  # Bless $self object into the $class pkg.
  return bless($self, $class);
}

################
# Methods to access per-object data.
# With args, they set the value.  Without any, they only retrieve it/them.

sub name {
  my $self = shift;

  if ( @_ ) { $self->{NAME} = shift }

  return $self->{NAME};
}


sub age {
  my $self = shift;

  if ( @_ ) { $self->{AGE} = shift }

  return $self->{AGE};
}


sub peers {
  my $self = shift;

  if ( @_ ) { @{ $self->{PEERS} } = @_ }

  return @{$self->{PEERS}};
}


sub exclaim {
  my $self = shift;

  return sprintf("\nexclaim: Hi, I'm %s, age %d, working with %s",
                         $self->name, $self->age, join(", ", $self->peers));
}


sub increm_bday {
  my $self = shift;

  print "increm_bday: Next $self->{NAME} bday is ...\n";
  return $self->age( $self->age() + 1 );
}


sub population {
  my $self = shift;

  print "population: Person count is ...\n";
  ref($self) ? return ${$self->{_CENSUS}} : return $Census;
}


# Decrement $Census when a Person is destroyed.
sub DESTROY {
  my $self = shift;

  ###if ( $Debugging ) { carp("debug: Destroying $self " . $self->name) }
  ###if ( $Debugging ) { warn("debug: Destroying $self " . $self->name) }
  if ( $Debugging || $self->{_DEBUG} ) { 
    warn("DESTROY: Destroying $self " . $self->name);
  }
  ###--$Census;
  --${$self->{_CENSUS}};
  print ${$self->{_CENSUS}}, " Person(s) remain\n";
}


sub debug {
  # TODO why not working in Main or global?
  ###use Carp;
  my $self  = shift;
  ###my $class = shift;
  my $level = shift;

  unless ( @_ == 1 ) { warn "debug usage: thing->debug(level)"  }
  ###if ( ref $class ) { warn "Class method called as object method\n"; }
  ref($self) ? $self->{_DEBUG} = $level : $Debugging = $level;
  ###unless ( @_ == 1 ) { confess("usage: CLASSNAME->debug(level)") }
  ###unless ( @_ == 1 ) { warn "usage: CLASSNAME->debug(level)"  }
  ###$Debugging = shift;
}


sub END {
  print "END: Beginning Person destruction...\n" if $Debugging;
}

1;  # so the require or use succeeds


#############
package Main;

$him = Person->new();
$him->name('Jason');
$him->age(23);
$him->peers('Norbert', 'Rhys', 'Phineas');

$her = Person->new();
$her->name('Jasonia');
$her->age(33);
$her->peers('Norbertia', 'Rhysia', 'Phineasia');

push(@all_recs, $him, $her);  # save object in array for later

printf("%s is %d years old.\n", $him->name, $him->age);
print "His peers are: ", join(", ", $him->peers), "\n";

printf "Last rec's name is %s\n", $all_recs[-1]->name;

# This only works if the sub is here in this Main pkg.
###print exclaim($him);
print $him->exclaim();
print $her->exclaim();
print "\n";
###print increm_bday($him);
print $him->increm_bday();
print "\n";
###print population($him);
print $him->population(), "\n";
# Get "Class method called as object method" message from sub debug.
###$him->debug(1);
###Person->debug(1);

__END__

=head1 NAME

Person - class to implement people

=head1 SYNOPSIS

use Person;
$ob = Person->new;

$count = Person->population;

=head1 DESCRIPTION

Implements foo

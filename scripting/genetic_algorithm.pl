#!/usr/bin/perl -w
##############################################################################
#     Name: genetic_algorithm.pl
#
#  Summary: GA demonstration with word DNA (512 bits)
#
#           TODO needs work
#
#  Adapted: Sun 15 Sep 2002 14:18:19 (Bob Heckel -- Ted Zlatnov IBM Devworks)
# Modified: Sun 22 Sep 2002 10:56:06 (Bob Heckel) 
##############################################################################
use strict;
use Data::Dumper;

# individuals in the population
my $popsize = 1024;			# a good starting point
my $dna_length = 512;			# 4 "letters" in the DNA
my $dna_byte_length = $dna_length / 8;	# the DNA byte length
my $mut_rate = 0.01;			# the mutation rate
my $min_fitness = 0.1;			# the minimum fitness for survival

my $generation_count = 100000;	        # run for this many generations
my $generation = 0;			# generation counter

my $pop_ref = [];                       # a reference to a population array

init_population($pop_ref, $popsize);

do
{
 evaluate_fitness($pop_ref, \&fitness);

 # print out a generation summary line
 my @sorted_population = sort { $a->{fitness},  $b->{fitness} } @$pop_ref;
 printf "generation %d: size %d\nleast fit DNA [%s]/%d\nmost fit DNA  [%s]/%d\n",
  $generation,
   scalar @sorted_population,
    dna_to_words($sorted_population[0]->{dna}),
     $sorted_population[0]->{fitness},
      dna_to_words($sorted_population[-1]->{dna}),
       $sorted_population[-1]->{fitness};

 survive($pop_ref, $min_fitness);       # select survivors from the population
 select_parents($pop_ref);
 $pop_ref = recombine($pop_ref);        # recombine() returns a whole new population array reference

 # from this point on, we are working with a new generation in $pop_ref
 mutate($pop_ref, $mut_rate);	        # apply mutation to the individuals
} while ($generation++ < $generation_count); # run until we are out of generations

sub init_population
{
 my $population = shift @_;
 my $pop_size = shift @_;

 # for each individual
 foreach my $id (1 .. $pop_size)
 {
  # insert an anonymous hash reference in the population array with the individual's data
  # the DNA is a random number
  my $random_dna = 0;
  foreach my $byte (1 .. $dna_byte_length)
  {
   vec($random_dna, $byte-1, 8) = int(rand(256));
#   printf "Byte $byte; Random DNA is now [%64s]\n", dna_to_words($random_dna);
  }
  push @$population, { dna => $random_dna, survived => 1, parent => 0, fitness => 0 };
 }
}

sub evaluate_fitness
{
 my $population = shift @_;
 my $fitness_function = shift @_;

 foreach my $individual (@$population)
 {
  # set the fitness to the result of invoking the fitness function
  # on the individual's DNA
  $individual->{fitness} = $fitness_function->($individual->{dna});
 }
}

sub survive
{
 my $population = shift @_;
 my $min_fitness = shift @_;
 my $survived = 0;

 foreach my $individual (@$population)
 {
  # set the fitness to 0 for unfit individuals (so they won't procreate)
  $individual->{survived} = $individual->{fitness} >= $min_fitness;
  if ($individual->{survived})
  {
   $survived++;
  }
  else
  {
   $individual->{fitness} = 0
  }
 }
 if (0 == $survived)
 {
  die "No individuals survived, dying peacefully";
 }
}

sub select_parents
{
 my $population = shift @_;
 my $pop_size = scalar @$population;	# population size

 # create the weights array: select only survivors from the population,
 # then use map to have only the fitness come through
 my @weights = map { $_->{fitness} } grep { $_->{survived} } @$population;

 # if we have less than 2 survivors, we're in trouble
 die "Population size $pop_size is too small" if $pop_size < 2;

 # we need to fill $pop_size parenting slots, to preserve the population size
 foreach my $slot (1..$pop_size)
 {
  my $index = sample(\@weights); # we pass a reference to the weights array here

  # do sanity checking on $index
  die "Undefined index returned by sample(), probably all individuals have died"
   unless defined $index;
  die "Invalid index $index returned by sample()"
   unless $index >= 0 && $index < $pop_size;

  # increase the parenting slots for this population member
  $population->[$index]->{parent}++;

 }
}

sub recombine
{

 my $population = shift @_;
 my $pop_size = scalar @$population;	# population size
 my @parent_population;
 my @new_population;

 my $total_parent_slots = 1;

 while ($total_parent_slots)
 {
  # find out how many parent slots are left
  $total_parent_slots = 0;
  $total_parent_slots += $_->{parent} foreach @$population;

  last unless $total_parent_slots;

  # if we are here, we're sure we have at least one individual with parent > 0
  my $individual = undef;		# start with an undefined individual
  do
  {
   # select a random individual
   $individual = $population->[int(rand($pop_size))];
   # individual is acceptable only if he can be a parent
   undef($individual) unless $individual->{parent};
  } while (not defined $individual);

  push @parent_population, $individual;	# insert the individual in the parent population
  $individual->{parent}--;		# decrease the parenting slots of the individual by 1

 }

 foreach my $parent (@parent_population)
 {

  # select a random individual from the parent population (parent #2)
  my $parent2 = @parent_population[int(rand($pop_size))];

  my $child = { survived => 1, parent => 0, fitness => 0, dna => 0 };

  # this is breeding!
  my $dna1 = $parent->{dna};
  my $dna2 = $parent2->{dna};  

  # note we do operations on BYTES, not BITS.  This is because bytes
  # are the unit of information (and preserving them is the faster
  # breeding method)
  foreach my $byte (1 .. $dna_byte_length)
  {
   # get one random byte from the parents and add it to the child
   vec($child->{dna}, $byte-1, 8) = vec(((rand() < 0.5) ? $dna1 : $dna2), $byte-1, 8);
  }

  push @new_population, $child;		# the child is now a part of the new generation
 }

 return \@new_population;
}

sub mutate
{
 my $population = shift @_;
 my $mut_rate   = shift @_;

 foreach my $individual (@$population)
 {

  # only mutate individuals if rand() returns more than mut_rate
  next if rand > $mut_rate;
  # mutate the DNA by and-ing and then or-ing it with two random
  # integers between 0 and 2^$dna_length
  my $old_dna = $individual->{dna};
  my $new_dna = 0;

  foreach my $byte (1 .. $dna_byte_length)
  {
   vec($new_dna, $byte-1, 8) &= int(rand(256));
   vec($new_dna, $byte-1, 8) |= int(rand(256));
  }

  $individual->{dna} = $new_dna;
#  print "Mutated $old_dna to ", $individual->{dna}, "\n";
 }
}

# this is a closure block!
{                               
 # private static variable @dictionary in closure for fitness() only
 my @dictionary;
 my %freqs;
 # calculate the fitness of the DNA
 sub fitness
 {
  my $dna = shift @_;  
  my $words = dna_to_words($dna);
  my $fitness = 0;			# start with 0 fitness
  my $max_entry_length = 20;		# longest word we accept

  # you can use any word list at the end of the program
  # do the @dictionary initialization just once
  unless (@dictionary)
  {
   @dictionary = '';
   foreach (@dictionary)
   {
    chomp;
   }   

   # eliminate words over $max_entry_length letters, and uppercase them
   @dictionary = grep { length($_) > 1  && length($_) < $max_entry_length }
    map { uc } @dictionary;
   # build the letter frequencies hash (remember, all letters are uppercase)
   $freqs{$_}++ foreach split '', join '', @dictionary;
  }

  # there is no easy way to avoid this exhaustive check of the dictionary
  # without complicating this example too much
  foreach my $entry (@dictionary, 'A'..'Z')
  {
   # do nothing if the entry is not matched in the DNA, or vice versa
   next unless $words =~ /$entry/;

   # we have a match!  (it may be a substring, that's OK)
   # increment the fitness depending on how long the match was;
   $fitness += 2**length($entry);
   $fitness+= $freqs{$entry} if exists $freqs{$entry};
  }
  return $fitness;
 } # end of fitness()
}

# Function to sample from an array of weighted elements
# originally written by Abigail <abigail@foad.org>
# Documentation for the algorithm is at
# http://theoryx5.uwinnipeg.ca/CPAN/data/Sample/Sample.html
# (the CPAN Sample module)
sub sample
{
 # get the reference to the weights array
 my $weights = shift @_ or return undef;
 # internal counting variables
 my ($count, $sample);

 for (my $i  = 0; $i < scalar @$weights; $i ++)
 {
  $count += $weights->[$i];
  $sample = $i if rand $count;

 }

 # return an index into the weights array
 return $sample;
}

# ASCII-centric byte to letter conversion
sub byte_to_letter
{
 my $dna = shift @_;
 my $byte = shift @_;
# print "Got byte $byte\n";
 my $letter = vec $dna, $byte, 8;
 # is the byte in the letter ranges? if so, return it.
 return chr($letter) if ($letter >= 65 && $letter <= 90);
 # if not, return a space.  the use of ord() every time could be cached.
 return ' '; 
}

# print the DNA out to a scalar
sub dna_to_words
{
 my $dna = shift @_;
 my @words;

 foreach my $byte (1.. $dna_byte_length)
 {
  # print the letter equivalent of the current byte
  push @words, byte_to_letter($dna, $byte-1);
 }

 # return the printable words
 return join '', @words;
}

__DATA__
about
algorithm
and
biology
by
century
come
computer
electronics
evolution
field
fitting
genetic
in
intriguing
is
it
most
of
one
only
progress
reach
rivaled
sciences
speed
that
the
to
was

#!/usr/bin/perl -w
##############################################################################
#    Name: grep_database.pl
#
# Summary: Search a simple, in-memory, database for restaurants.
#
# Adapted: Tue 13 Mar 2001 17:08:31 (Bob Heckel --
#                       http://www.raycosoft.com/rayco/support/perl_tutor.html)
##############################################################################
use strict;

# (Normal) array of references to anonymous hashes:
my @database = 
  ( { name      => "Wild Ginger", 
      city      => "Seattle",
      cuisine   => "Asian Thai Japanese",
      parking   => "\0",
      rating    => 2, 
    },
    { name      => "Ferraros", 
      city      => "Westfield",
      cuisine   => "Italian American Pizza",
      parking   => "\0",
      rating    => 5, 
    },
#   { ... },  etc.
  );

my %query = ( city => 'Westfield', cuisine => 'Italian|Pizza', min_rating => 3 );

my @restaurant = find_restaurant(\@database, \%query);

print "$restaurant[0]{name} in $restaurant[0]{city}\n" if @restaurant;
print "Sorry, nothing found.\n" if ! @restaurant;


sub find_restaurant {
  my ($db, $qry) = @_;

  return grep {
    $$qry{city}       ? lc($$qry{city}) eq lc($$_{city})  : 1 and 
    $$qry{cuisine}    ? $$_{cuisine} =~ /$$qry{cuisine}/i : 1 and 
    $$qry{parking}    ? $$_{parking}                      : 1 and 
    $$qry{min_rating} ? $$_{rating} >= $$qry{min_rating}  : 1 and 
    $$qry{max_rating} ? $$_{rating} <= $$qry{max_rating}  : 1 
  } @$db;
}


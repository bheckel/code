#!/usr/bin/perl -w
##############################################################################
#     Name: slice.pl
#
#  Summary: Access pieces of arrays and hashes.
#
#  Adapted: Mon 03 May 2004 15:04:56 (Bob Heckel -- Steve's Place Perl tut)
##############################################################################

# Array slice:
@array = ( "Hello", "everybody", "I'm", "Dr.", "Nick", "Riviera" );
print "@array\n";

@array[3, 4, 5] = ( "A", "complete", "charlatan" );
print "@array\n";


# Hash slice:
%trees = (
  apple =>  "Malus",
  pear  =>  "Pyrus",
  plum  =>  "Prunus",
  oak   =>  "Quercus",
  ash   =>  "Fraxinus",
  yew   =>  "Taxus",
);
# Remember that $, @ and % aren't really part of the name of a variable, they
# are ways of accessing and creating data of a specific type. 
#                             _
@latin_names_of_fruit_trees = @trees{'apple', 'pear', 'plum'};
print "@latin_names_of_fruit_trees\n";

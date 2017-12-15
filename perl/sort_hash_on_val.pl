#!/usr/bin/perl -w
##############################################################################
#     Name: sort_hash_on_val.pl
#
#  Summary: Sort an anonymous array of hash references by their value.  
#
# Adapted: Thu 30 May 2002 09:30:04 (Bob Heckel -- Teodore Zlatanov 
#                                    IBM DevWorks)
# Modified: Mon 29 Mar 2004 15:35:15 (Bob Heckel)
##############################################################################
use Data::Dumper;

# Example 1:
############

%h = ('a', 1, 'b', 3, 'c', 2);

foreach $k (sort { $h{$a} cmp $h{$b} } keys %h) {
  print "$k key is $h{$k} sorted ascending by val\n";
}

__END__



# Example 2:
############

# Sort by hash member.

# Create a list with 3 hash references.
@old_list = ( { thekey => 'zoo' }, { thekey => 'joe' }, { thekey => 'moe' } );

# Sort @old_list by the value of the 'thekey' key.
@new_list = sort { $a->{thekey} cmp $b->{thekey} } @old_list;

print Dumper(@new_list);

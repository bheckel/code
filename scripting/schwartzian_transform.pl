#!/usr/bin/perl -w
##############################################################################
#     Name: schwartzian_transform.pl
#
#  Summary: Sort using Randal Schwartz' construct.  
#
#           You would use this when it's expensive to obtain data from the
#           objects being sorted.  E.g.  applying split() to a string every
#           time we need to obtain the value to sort by.
#
#           Any time you need to do complex sorting, see if the Schwartzian
#           transform or the Guttman-Rosler transform are appropriate. They
#           are drop-in functional replacements for regular sorting. 
#
#  Adapted: Fri 16 Mar 2001 13:40:21 (Bob Heckel -- from RayCosoft website)
# Modified: Wed 04 Dec 2002 09:26:00 (Bob Heckel)
##############################################################################

# Precompute keys, sort, extract results (the famous Schwartzian transform).

@filenames = qw(helloworld.pl hashmerge.pl map.pl hash.pl);

# Map() transforms the list.
@sorted = map { $_->[0] } 
          sort { $a->[1] <=> $b->[1] } 
          map { [ $_, -M ] } 
          @filenames  # -M provides the last modi date
          ;

print "@sorted\n\n";


#####################


@old_list = ('16 wins', '1 Cup', '4 rounds', 'Stanley');

# Sort @old_list by the first word in each string, numerically.
#
# @old_list is never actually modified here.
#
#  $_->[1] means "rewrite $_ to be the value stored in the second object in
#  the list that $_ refers to."                                                                     
@new_list = map($_->[1], 
                sort({ $a->[0] cmp $b->[0] }
                       map([ (split)[0], $_ ], @old_list)
                     )
               );

print "@new_list\n\n";


#####################

# Sort on specific column:

$str =<<'EOT';
eir    11   9   2   6   3   1   1   81%   63%   13
oos    10   6   4   3   3   0   4   60%   70%   25
hrh    10   6   4   5   1   2   2   60%   70%   15
spp    10   6   4   3   3   1   3   60%   60%   14

EOT


# Sort the contents using the last field as the sort key. 
$str = join "\n", 
       map { $_->[0] }
       sort { $a->[1] <=> $b->[1] }
       map { [ $_, (split)[-1] ] }
       split /\n/, $str; 


print $str, "\n";

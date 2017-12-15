#!/usr/bin/perl
##############################################################################
#     Name: parent_child_anon_hash_array.pl
#
#  Summary: Simple use of references to build a hash of array of hashes
#           to represent a parent-child relationship
#
#  Adapted: Tue Sep 11 16:25:15 2007 (Bob Heckel --
#  http://www.unix.org.ua/orelly/perl/advprog/ch01_03.htm)
# Modified: Tue 12 Feb 2013 13:22:52 (Bob Heckel)
##############################################################################
use warnings;

###%parent = (              # Parent
###    'name' => 'Sue',
###    'age'  => '45');
###
###%john = (             # Child
###    'name' => 'John',
###    'age'  => '20');
###
###%peggy = (            # Child
###    'name' => 'Peggy',
###    'age'  => '16');
###
###@children = (\%john, \%peggy);
###$parent{'children'} = \@children;
#### or better, avoid @children array
######$parent{'children'} = [\%john, \%peggy];
###
###print $parent{children}->[1]->{age};
#### or
######print $parent{children}[1]{age};

# better, no intermediate hashes or arrays
###%parent = (                                 # Parent
###    'name'     => 'Sue',
###    'age'      => '45',
###    'children' => [                         # Child anon array of two hashes
###                      {                     # Child anon hash 1
###                         'name' => 'John',
###                         'age'  => '20'
###                      },
###                      {                     # Child anon hash 2
###                         'name' => 'Peggy',
###                         'age'  => '16'
###                      }
###                  ]
###);
###print $parent{children}[1]{age};

# or best using autovivification:
$parent{name} = 'Sue';  # not mandatory, child can be parentless
$parent{children}[1]{name} = 'Peggy';
$parent{children}[1]{age} = 16;

print $parent{name} . ' is parent of ' . $parent{children}[1]{name} . ', age ' . $parent{children}[1]{age};

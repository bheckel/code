#!/usr/bin/perl
##############################################################################
#     Name: simple_references_datastructs.pl
#
#  Summary: Simple use of references to build a hash of array of hashes
#
#  Adapted: Tue Sep 11 16:25:15 2007 (Bob Heckel --
#  http://www.unix.org.ua/orelly/perl/advprog/ch01_03.htm)
##############################################################################
use warnings;

###%sue = (              # Parent
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
###$sue{'children'} = \@children;
#### or better
######$sue{'children'} = [\%john, \%peggy];
###
###print $sue{children}->[1]->{age};
#### or better
######print $sue{children}[1]{age};

# better, no intermediate arrays
###%sue = (                                    # Parent
###    'name'     => 'Sue',
###    'age'      => '45',
###    'children' => [                         # Anon array of two hashes
###                      {                     # Anon hash 1
###                         'name' => 'John',
###                         'age'  => '20'
###                      },
###                      {                     # Anon hash 2
###                         'name' => 'Peggy',
###                         'age'  => '16'
###                      }
###                  ]
###);
###print $sue{age}, "\n";
###print $sue{children}[1]{age};

# or best:
$sue{children}[1]{age} = 16;

print $sue{children}[1]{age};

#!/usr/bin/perl -w
##############################################################################
#    Name: hash_of_array_of_hash.pl
#
# Summary: Create complex datastructure to model a Checklist.  
#          Uses a hash of anonymous arrays of hashes.
#
# Created: Mon 05 Mar 2001 14:58:35 (Bob Heckel)
##############################################################################

use ConfLib;
#--------------------------------------------------------------------
# Desired (abbreviated) output.
%cklist = ( prebuild => [
                          { a_date => 9876 ,  group => 'prodeng' },
                          { a_date => 9877 ,  group => 'qrodeng' },
                        ],

               build => [
                          { a_date => 5432 ,  group => 'ooeng'},
                          { a_date => 5433 ,  group => 'poeng'},
                          { a_date => 9999 ,  group => 'found'},
                        ],
          );


print $cklist{build}[2]{group};
#--------------------------------------------------------------------

# Populate data structure from file.
$cfg = new ConfLib;
$cfg->load("/home/bheckel/junk") || die "$0--Can't open file: $!\n";
@allsects = $cfg->sectionList;

# Build hash of anon arrays of hashes.
foreach $mainsect ( 'prebuild', 'build', 'postbuild' ) {
  foreach $subsect ( @allsects ) {
    next unless $subsect =~ m/^$mainsect/;
      %sect = $cfg->section($subsect);
      push(@aoh, { %sect }); 
  }
  $hoa{$mainsect} = [ @aoh ];
}

print $hoa{prebuild}[1]{group};

__END__
Sample of 'junk'

[prebuild:1]
a_date=959572800
group=prodengx

[prebuild:2]
a_date=2345
group=we have a winner

[build:1]
a_date=
group=

[postbuild:1]
a_date=
group=prodengroceng

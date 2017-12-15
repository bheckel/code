#!/usr/bin/perl -w
##############################################################################
#     Name: hash_of_hashes.pl
#
#  Summary: Demo using a hash of hashes data structure
#
#  Adapted: Thu 11 Dec 2003 11:02:48 (Bob Heckel --
#                            file:///C:/Perl/html/lib/Pod/perldsc.html)
##############################################################################


########################################
# Load from variable:
#          key                    value
#       ___________    _____________________________________
%HoH = (flintstones => { LEAD => 'fred', PAL  => 'barney', },
        jetsons => { LEAD => 'george', WIFE => 'jane', 'HIS BOY' => 'elroy', },
        simpsons => { LEAD => 'homer', WIFE => 'marge', KID  => 'bart', },
       );

print $HoH{jetsons}{WIFE}, "\n\n";

$HoH{spongebob}{LEAD} = 'Bob';

# Iterate the hash of hashes.
for $family ( keys %HoH ) {
  for $role ( keys %{ $HoH{$family} } ) {
    print $HoH{$family}{$role}, "\n";
  }
}

print "\n";


########################################
%HoH = ();
# Load from file:
while ( <DATA> ) {
  # Harvest the WORD: prefix.
  next unless s/^(.*?):\s*//;
  $family = $1;
  # Now it's just LEAD=fred FRIEND=barney...
  for $field ( split ) {
    ($role, $name) = split '=', $field;
    $HoH{$family}{$role} = $name;
  }
  
}

# Iterate the hash of hashes.
for $family ( keys %HoH ) {
  for $role ( keys %{ $HoH{$family} } ) {
    print $HoH{$family}{$role}, "\n";
  }
}


__DATA__
flintstones: LEAD=fred FRIEND=barney
jetsons: LEAD=george FRIEND=jane SON=elroy

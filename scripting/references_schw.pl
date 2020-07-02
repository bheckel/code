#!/perl/bin/perl -w

# REFERENCES -- From Schwartz Unix Review Col 7 March 96.


$a = 43;
# Create reference to scalar $a.
$ref_to_a_scalar = \$a;
print "$ref_to_a_scalar\n";       # Outputs: SCALAR(0xb75e3c)
print "${$ref_to_a_scalar}\n";    # Outputs: 43
print "$a\n\n";                   # Outputs: 43

# Dereference with $$, effectively giving $a a new value.
$$ref_to_a_scalar = 66;       
print "$ref_to_a_scalar\n";       # Outputs: SCALAR(0xb75e24)
print "$$ref_to_a_scalar\n";      # Outputs: 66
# $a has been changed indirectly via the reference to it.
print "$a\n\n";                   # Outputs: 66

print "...............\n";

@bs = ('a', 'b', 'c');
print "@bs\n";                    # Outputs a b c
# Create reference to list @bs.
$ref_to_bs_list = \@bs;
print "$ref_to_bs_list\n";        # Outputs ARRAY(0xb75ee4)
# Dereference with @$, effectively giving @bs new values.
@$ref_to_bs_list = (3,4,5);
print "$ref_to_bs_list\n";        # Outputs ARRAY(0xb75ee4)
print "@$ref_to_bs_list\n";       # Outputs 3 4 5
print "$#$ref_to_bs_list\n";      # Outputs 2
# @bs has been changed indirectly via the reference to it.
print "@bs\n\n";                  # Outputs 3 4 5

# Add 8 & 9 to the array.
push(@$ref_to_bs_list,8,9);
print "$ref_to_bs_list\n";     # Outputs ARRAY(0xb75ee4), same as it ever was.
print "@$ref_to_bs_list\n";    # Outputs 3 4 5 8 9
print "$#$ref_to_bs_list\n";   # Outputs 2
print "@bs\n\n";               # Outputs 3 4 5 8 9

foreach $ref_to_bs_list (\@bs) {
        @$ref_to_bs_list = ();    # Clear out the array.
}
print "Place hold \$ref_to_bs_list \=  $ref_to_bs_list
       Place hold \@\$ref_to_bs_list \=  @$ref_to_bs_list 
       Place hold \$\#\$ref_to_bs_list \=  $#$ref_to_bs_list
       Place hold \@bs \= @bs\n\n";


print "...............\n";

# Anonymous list (creating only a reference to these numbers):
$var_w_no_real_name = [ 2, 4, 6, 8 ];

# Find out its size:
$length = @$var_w_no_real_name;
print $length . "\n";      # Outputs 4

# Increment its first element, from 2 to 3:
$$var_w_no_real_name[0]++;
print $var_w_no_real_name . "\n";   # Outputs ARRAY(0xb78250)
print "@$var_w_no_real_name\n";     # Outputs 3 4 6 8


print "...............\n";


@a = 1..1000;
$ref_to_scalar_a = \@a;   # $ref_to_scalar_a Holds an address.

print "$ref_to_scalar_a\n";  # Outputs ARRAY(0xb7825c)
print "@$ref_to_scalar_a\n"; # Outputs 1 2 3 4 5 6 7 8 9 10 11 12 13 ...

&brak_it($ref_to_scalar_a);  # Outputs  [1][2][3][4][5][6][7][8][9][10][11] ...

# Expects a list reference as its 1st arg.  Then it dereferences that arg to
# get the actual list.  W/o references, would have to make a copy of all 1000
# elements to hand to the subroutine.
sub brak_it {
  print "@_\n";             # Outputs ARRAY(0xb7825c)
  my($firstparam) = @_;
  foreach (@$firstparam) {
    print "[$_]";
  }
  print "\n";       
}

# Anonymous list ref as argument.
&brak_it([10, 20, 30]);     # Outputs [10][20][30]
# When this sub returns, the 2 references to the anon list ref disappear,
# leaving no references to the data 10 20 30.  Perl then disposes of the memory
# that was holding the list.

print "...............\n";

$a = [50, 60, 70];          # $a is a listref.
$b = $a;
@c = (1, 2, 3);
###push(@c, @$a); WRONG.
push(@$a, @c);
print "@$a\n";              # Outputs 50 60 70 1 2 3
print "@$b\n";              # Outputs 50 60 70 1 2 3
undef $a;
print "@$a\n";              # Outputs
print "@$b\n";              # Outputs 50 60 70 1 2 3   Not wiped by undef.

print "...............\n";


# Ref to hash:

# %score is the "real" hash.  \%score is a single scalar that is easy to pass
# to functions, etc.
$hash_ref = \%score;                                               
print "$hash_ref\n\n";      # Where %score is located in memory: HASH(0x659e48).
# Same as $score{"fred"} = 205 or $$hash_ref{"fred"} = 205;
${$hash_ref}{"fred"} = 205;
# Same as $score{"barney"} = 195
$$hash_ref{"barney"} = 195;      
# Same as @score{"wilma","betty"} = (170,180);      
@$hash_ref{"wilma","betty"} = (170,180);
# Same as @the_keys = keys %score                              
@the_keys = keys %$hash_ref; 
print "@the_keys\n\n";

# Now do same print via a subroutine, PASSING a reference.
&show_hash(\%score);

sub show_hash {
  my($hash_ref) = @_;
  foreach (sort keys %$hash_ref) {
    print "$_ is the key for value $$hash_ref{$_}\n";
  }
}

print "...............\n";

# RETURN BACK a reference.
$list_ref = &return_it();
print "$$list_ref[4]\n";

sub return_it {
  my(@listit) = 1..100;
  return \@listit;
}


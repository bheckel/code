#!/usr/bin/perl -w
##############################################################################
#     Name: hash.pl
#
#  Summary: Demo of hash manipulation.
#
#           See hash_of_anonarrs.pl to use a hash with multiple values (e.g.
#           a passwd datastructure).
#
#  Created: Thu, 25 Nov 1999 13:44:27 (Bob Heckel)
# Modified: Tue 22 Apr 2014 14:05:54 (Bob Heckel)
##############################################################################

sub make_sundae {
  my %parameters = (
    flavor    => 'Vanilla',
    topping   => 'fudge',
    sprinkles => 100,
    @_,
  );

  while ( (my $k, my $v) = each %parameters ) { print "$k=$v\n"; }
}

make_sundae(flavor=>'LemonBurst',topping=>'cookiebits');

  __END__



%myhash = map(/(\w+)\t(\w+)/, <DATA>);

print keys %myhash, "\n";
# Same
# You *can* loop over the list of keys and values with a for loop, but the
# iterator variable will get a key on one iteration and its value on the next,
# because Perl will flatten the hash into a single list of interleaved keys and
# values.
foreach $k (keys %myhash) {
  print "$k\n";
}

print values %myhash, "\n";
# Same
foreach $v (values %myhash) {
  print "$v\n";
}

# Number of elements in hash.
print scalar keys %myhash;


# Misc from www.cgi101.com
# delete $hash{$key}    deletes the specified key/value pair,
#                       and returns the deleted value
# exists $hash{$key}    returns true if the specified key exists
#                       in the hash.
# keys %hash            returns a list of keys for that hash
# values %hash          returns a list of values for that hash
# scalar %hash          returns true if the hash has elements
#                       defined (e.g. it's not an empty hash)


# Print each key-value pair.
%NumberWord = ('1' => 'One', '2' => 'Two', '3' => 'Three');
while (($key, $value) = each(%NumberWord)) {
  print("$key: $value\n");
  print "DEBUG: $_\n";
}


##########

# Use x repetition operator to initialize a hash slice:
@keys = qw(perls before swine);
@hash{@keys} = ("") x @keys;
# Same as:
$hash{perls} = "";
$hash{before} = "";
$hash{swine} = "";

##########


# From p.220 Blue Camel 3rd Edition.
paramtesting(PASSWORD=>"yyz", VERBOSE=>9);

sub paramtesting {
  my %options = @_;

  print "hash: $options{PASSWORD}\n";
}


##########

# Load hash in one line using a hash slice:
@hash{"key1", "key2"} = (1,2);


##########

# Delete multiple hash values at once.
delete @ENV{qw(ENV PATH)};
print $ENV{PATH};



__DATA__
foo	bar
baz	boom

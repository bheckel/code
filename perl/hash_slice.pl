   

# Hash slice: 
@hash{@array} = (list)
# This is semantically equivalent to: 
( $hash{ $array[0] }, ... $hash{ $array[$#array]  } ) = ( list )
# Remember that the @ means an array _context_ but it is the {} after the
# variable name that marks it as a hash. All hashes use {} and all arrays use
# []. !!!The prefix char is used ONLY to mark context, not data type!!!



# Hash Slices
# Written by Uri Guttman
# --------------------------------------------------------------------------------
# 
# The Challenge (as posted on comp.lang.perl.misc)
# I once posted to c.l.p.misc (comp.lang,perl.misc) this code and i asked what
# good is it? 
  @array = qw( a b c d ) ;

  @array{ @array } = ( [ @array ] ) x @array ;
# 
# 
# --------------------------------------------------------------------------------
# 
# The Answer and Explanation
# There is a very useful perl idiom here which all good perl hackers should have
# in their vocabulary. It is called hash slices, and it has many different uses
# which I will illustrate. It is a rare perl script (which is not trivially
# small) that couldn't use hash slices to improve its efficiency, clarity and
# elegance. 
# 
# The fundamental hash slice expression is: 

  @hash{ @array } = ( list )

# This is semantically equivilent to: 
 ( $hash{ $array[0] }, ... $hash{ $array[$#array]  } ) = ( list )

# That means you are doing an array assignment to a list of entries in the hash.
# Each entry is indexed by the next array value and is assigned corresponding
# value in the list. The list as always can be any combination of list values and
# arrays. 

# The hash slice can be indexed by a list instead of an array, but I haven't
# found it to be as useful (though it is used sometimes) so I won't go into it
# here. 

# NEWBIE NOTE:
# Remember that the @ means an array context but it is the {} after the variable
# name that marks it as a hash. Many newbies fall for this trap. All hashes use
# {} and all arrays use []. The prefix char is used ONLY to mark context, not
# data type. 



# --------------------------------------------------------------------------------

# What are the interesting ways of assigning to a hash slice?
# The simplest is when you have two arrays of values and you want a hash to
# convert a value from one array to another. 
# 
  @foo_array = qw( abc def ghi ) ;
  @bar_array = qw( jkl mno pqr ) ;

  @foo_to_bar{ @foo_array } = @bar_array

# Now you can easily convert from foo values to bar values like this: 
  $foo_value = 'def' ;
  $bar_value = $foo_to_bar{ $foo_value } ;
  $bar_value now is 'mno'

# You can even convert a whole array of foo values in one statement: 
  @bar_values = @foo_to_bar{ @foo_values } ;

# Another very common hash slice idiom I use all the time is testing if a string
# is in a given list of strings. We actually don't care about the values in the
# hash but I use 1 for clarity and to skip the need for exists (though exists
# might be faster I have never benchmarked it. I leave that as an assignment for
# the reader). 

  @foo_array = qw( abc def ghi ) ;

  @is_a_foo{ @foo_array } = (1) x @foo_array ;

  $input = 'def' ;

  if ( $is_a_foo{ $input } ) {
	...

# or 
  if ( exists( $is_a_foo{ $input } ) ) {
	...

# The assignment uses an interesting operator that most newbies never have seen.
# It is called the repetition operator and it is just the plain letter 'x'. It
# duplicates its left operand by the value of its right operand. In a scalar
# context, it replicates its left operand as a string and returns that. In this
# case we have a list context and a left operand of a list, so it creates a new
# list with N duplicates of the list. In this case N is 3 (the scalar value of
# @foo_array), so we get a list of (1, 1, 1) which is assigned to the hash slice. 

# A variant on the existance test is conversion from a string to an numerical
# index value. We use the range operator (..) to generate the list of integers
# which is assigned to the hash slice. 

@foo_array = qw( abc def ghi ) ;

# for 0 based use: 
@foo_to_index{ @foo_array } = ( 0 .. $#foo_array ) ;

# for 1 based use: 
@foo_to_index{ @foo_array } = ( 1 .. @foo_array ) ;

$i_am_a_foo = 'def' ;

$foo_index = $foo_to_index{ $i_am_a_foo } ;

# Note that this form can also be used to test if a value is a foo as well as
# converting it to an index. Remember though, that if you use the 0 (zero) based
# version, you MUST use exists since the value 0 will be false for the simple
# test. 

# NEWBIE NOTE:
# Notice the selection of names for each of the hashes, %foo_to_bar, %is_a_foo,
# $foo_to_index. They are very descriptive of the operation they perform. In fact
# I treat them as very fast and simple subroutines. Indexing into a hash is a
# transformation of the input data fto the output values. Thinking this way will
# make your Perl scripts much easier to design and write. 

# Now, let us look at the original quiz version of the hash slice idiom. 

@array{ @array } = ( [ @array ] ) x @array ;

# The first thing to notice is that the hash and the array are both named array
# but they are different variables. Hashes and arrays (and scalars) have
# different namespaces. I chose the same name to make the quiz a little trickier.
# Other than that, the left side is just an assignment to a hash slice, but what
# is being assigned? 

# Notice that there is the 'x' operator and @array on its right as its
# replication count and some list on its left and we are in a list context (hash
# slices are list contexts). So we are creating a replicated list of an anonymous
# array which contains the values in @array. This means the hash %array looks
# like this: 

  %array = (
	'a' => [ 'a', 'b', 'c', 'd' ],	
	'b' => [ 'a', 'b', 'c', 'd' ],	
	'c' => [ 'a', 'b', 'c', 'd' ],	
	'd' => [ 'a', 'b', 'c', 'd' ],	
  ) ;

# Except that all the anonymous arrays are the same one (the above code creates 4
# different anonymous arrays with the same values). 



# --------------------------------------------------------------------------------

# What good is this structure?
# Well, I was thinking about alias expansion when I devised this. What if you had
# a set of aliases and you wanted to expand any one of them to the full list.
# This data structure will do that. Enter any of the single elements and you get
# the entire list. By itself it isn't much, but what if you had multiple sets of
# aliases? You could do this: 

  @foo_list = qw( a b c d ) ;
  @bar_list = qw( j k l m n o ) ;
  @baz_list = qw( w x ) ;

  @expand_aliases{ @foo_list } = ( [ @foo_list ] ) x @foo_list ;
  @expand_aliases{ @bar_list } = ( [ @bar_list ] ) x @bar_list ;
  @expand_aliases{ @baz_list } = ( [ @baz_list ] ) x @baz_list ;

# Now, if you had a single token of unknown type you could get its alias list in
# one step: 
  @aliases = @{ $expand_aliases{ $alias } } ;

# NEWBIE NOTE:
# The surrounding @{} is used to dereference the stored anonymous list back into
# a list for assignment to @aliases. 

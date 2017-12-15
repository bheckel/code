# my @foo = map { transform($_) } grep { choose($_) } @list;

#  From perlarchive.com Aug 2000 Simon Cozens article.
#
# Perl's grep differs from Unix in two ways: it works on an array instead of a
# file, and it's extremely general. Unix grep prints the lines in a file that
# match a regular expression - Perl grep returns the elements in an array that
# match a condition.  grep is a filter.
# 
# There are two forms of grep.  The easiest to understand is grep BLOCK LIST:

    @packages = grep { /findMe/ } @lines;

# Assuming we've got a set of lines of text in @lines, @packages will contain
# only those which have the word 'findMe' somewhere in them. In this way, grep
# is a filter - it filters out those elements which don't match the condition.
# Unlike Unix's grep, we can test for any condition, not just a regular
# expression matching. Here, for instance, we get an array of numbers which are
# over 50, filtering out those which are not:

    @big_numbers = grep { $_ > 50 } @numbers;

# Just like foreach, grep sets $_ to each element of the list in turn, and
# builds up a list of those for which the condition in the block is true. In
# fact, the statement above is pretty much equivalent to this:

    @big_numbers = ();
    foreach (@numbers) {
        push @big_numbers, $_ if $_ > 50;
    }

# The second form of grep, grep EXPR,LIST does exactly the same thing but is
# used when you have a single expression: a Perl built-in function or regular
# expression. So, for instance, to filter out all the undefined elements from an
# array, use this:

    my @array;
    $array[5] = "yellow"; $array[12] = "green"; $array[50] = "blue";

    @array = grep defined, @array;

# That's just the same as saying

    @array = grep { defined $_ } @array;
 
# and in both cases, you'll end up with

    @array = ("yellow", "green", "blue");

# Likewise, these two lines are equivalent:

    @packages = grep { /findMe/ } @lines;
    @packages = grep /findMe/, @lines;

# The second form is shorter, but I prefer the first because it gives you more
# flexibity and is also easier to read.

# grep is a counter

# As you might expect, if you call grep in a scalar context, you can get a
# count of how many items match the condition:

    $count = grep { /findMe/ } @lines;

# will tell you how many lines matched the pattern. We can also call grep a
# counter, since it counts the matching elements in an array.

# grep is a finder - but so are hashes
# 
# Naturally, since grep filters out those things which don't match a condition,
# you can just as easily say that grep is a finder, for finding the elements
# that do match the condition. Remember that you don't have to test $_ itself in
# the block; if you've got a array full of references to hashes, you might want
# to say this:

    @fishers = grep { $_->{occupation} eq "Fisher" } @people;

# This is fine if you know you're looking for more than one element, but if
# you're just testing to see if an element is in the array, why aren't you using
# a hash? Hashes are designed to make it easy for you to look up individual
# values. Next month, we'll see how to use map to turn an array into hash,
# amongst other things, but here's another way to do it. Instead of saying this:

    if (grep { $_ eq "Albert" } @array) {
        ...
    }
    if (grep { $_ eq "Bonnie" } @array) {
        ...
    }

# it's far neater to do something like this:

    $hash{$_} = 1 for @array;
    if (exists $hash{"Albert"}) {
        ...
    }
    if (exists $hash{"Bonnie"}) {
        ...
    }

# This way, you're not doing a scan over every element of the array each time
# you look for a certain element - just a simple look-up. It's faster because
# the time it takes to scan through an array depends on the size of the array:
# the mathematically inclined call this order n (or just O(n)), because as the
# size of your data (n) increases, the time taken increases too. The hash
# lookup, on the other hand, takes roughly the same time no matter how big the
# hash it - we'd call that O(1) because the time taken doesn't change depending
# on n.

# Hash Slices

# We created the hash by setting the hash value to one for each element of
# the array:

    $hash{$_} = 1 for @array;

# Perl cognoscenti might do this with a hash slice, like this:

    @hash{@array} = ();

# A hash slice is a neat way of setting several elements of a hash at once.
# Just like a list slice, you have a list of elements and a list of values:

    @array[3,4,5] = ("rock", "paper", "scissors");

# Except with a hash slice, the elements are the keys to the hash. This:

    @beats[("rock", "paper", "scissors")] = ("blunts", "wraps", "cuts");
 
# is the same as this:

    $beats{rock} = "blunts"; $beats{paper} = "wraps"; 
    $beats{scissors} = "cuts";

# Why does @hash{@array}= (); start with an @-sign? It's because we're assigning
# to a list of keys, not a single scalar or the whole hash. And why the ()?
# Well, we only need to make sure the key exists, so we can test it with exists
# - we don't care what it contains. () will make all the keys exist but have an
# undefined value; that's enough for our purposes. If you wanted to make them
# have a true value, you'd say something like this:

    @hash{@array} = (1) x @array;

# The right-hand side will now be a list containing as many 1s as there are
# elements in the array: the x operator can be used to repeat lists as well as
# strings.

# Locating Elements
# 
# Now what about if we want to keep track of whereabouts in the array where the
# matches occurred? The trick here is to use grep to loop over the indices of
# the array, rather than the actual values:

    @results = grep { $array[$_] =~ /findMe/ } (0..$#array)
    
# $#array is the index of the highest defined element, so (0..$#array) will give
# us all the indices in the array. We check to see if the element for each index
# contains findMe and if it does, we add that element to our list of results.
# This is all just a funny form of

    foreach (0..$#array) {
        push @results, $_ if $array[$_] =~ /findMe/
    }

# Now @results contains a list of all the indices where the condition matched.
# We can use this to look at the elements on either side of the match, which we
# might want to do if we want to provide context for displaying the match:

    foreach (@results) {
        print $array[$_-1] if $_>1;          # Line before
        print $array[$_];
        print $array[$_+1] if $_

# Or, to get a variable number of lines of context:

    foreach (@results) {
        for (-$context..$context) {
            print $array[$_] if $_ and $_


# Alternatively, we can use it to save the results if we're going to be
# changing them frequently and don't want to perform a grep every time.

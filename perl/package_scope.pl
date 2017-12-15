#!/usr/bin/perl -w
##############################################################################
#     Name: package_scope.pl
#
#  Summary: Demonstrate package and lexical variables.  
#           Note: the following code will generate warnings with the -w
#           switch, and won't even compile with "use strict".
#
#           If you think of package like cd, and :: as /, all will become
#           clear.  Maybe.
#
#           The package represents the source code and the namespace represents
#           the entity created when Perl parses that code.
#
#  Adapted: Sat 02 Feb 2002 11:20:17 (Bob Heckel -- Teodor Zlatanov Road To
#                                     Better Programming IBM DeveloperWorks)
# Modified: Fri 11 Apr 2014 13:04:21 (Bob Heckel)
##############################################################################
# Default, no need to type this:
###package main;

# This is a global package variable; you shouldn't have any with "use strict"
# it is implicitly in the package called "main".  Note no "my".
$global_sound = "";  # TODO why does this have to be here to print 'pigs do it...'?


# You can define several packages in one file, like this, or spread one over
# several files, but the "natural" size of one package is one file.
package Cow;
# This is a package variable, accessible from any other package as $Cow::sound
$sound = "moo";
# This is a lexical variable, accessible anywhere in this file, even un-prefixed
my $lexical_sound = "stampede!!";



package Pig;   # the Pig package starts, Cow ends but is still visible.
# This is a package variable, accessible from any other package as $Pig::sound
$Pig::sound = "oink";                     
$::global_sound = "pigs do it better";    # another "main" package variable



# We're back to the default package but this is confusing.
package main;
print "Cows go: ", $Cow::sound, "\n";  # prints "moo"
print "Pigs go: ", $Pig::sound, "\n";  # prints "oink"
# Important: note that the file-scoped lexical variable $lexical_sound is
# accessible in *all three* packages ("main", "Pig", and "Cow") because they
# are all defined within the same *file* in this example. Normally, each
# package is defined within its own file, ensuring that lexical variables are
# private to the package and you get encapsulation.  This example is not
# typical:
print "\nLexical: ", $lexical_sound;    # prints "stampede"
print "\nEveryone says: $global_sound\n"; # prints "pigs do it better"
print "\nHere comes a Perl error...";
print "\nWhat's this I hear: ", $sound;   # $main::sound is undefined!

#!/usr/bin/perl -w
##############################################################################
#     Name: pass_arrref_to_sub.pl
#
#  Summary: Prevent list flattening by passing an array reference to a sub.  
#           This uses references for both input and output.
#
#  Adapted: Wed 18 Apr 2001 10:03:58 (Bob Heckel -- p. 225 Camel v3)
# Modified: Fri 23 Apr 2004 09:49:05 (Bob Heckel)
##############################################################################

@c = qw(long one two three);
@d = qw(SHORT ARR);

($biggestref, $smallestref) = UsingRefs(\@d, \@c);
#                                                  simpler syntax
print "@{$biggestref}\n===> has more elements than \n@$smallestref\n";
#                                                      ^^^^^^^^^^^

print "\n";

NotUsingRefs(@d, @c);


sub UsingRefs {
   my ($cref, $dref) = @_;
 
   for $e ( @$dref ) {
     push @newarr, $e;
   }
   print "@newarr";

   ###if ( @{$cref} > @{$dref} ) {
   # Better
   if ( @$cref > @$dref ) {
     return $cref, $dref;
   } else {
     return $dref, $cref;
   }
}


sub NotUsingRefs {
   my (@carr, @darr) = @_;  # arrays are flattened so @darr gets nothing
 
   for ( @carr ) {
     print "c: $_ ";
   }

   for ( @darr ) {
     print "d: $_ ";
   }
}

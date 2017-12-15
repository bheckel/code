#!/usr/bin/perl -w
##############################################################################
#     Name: linked_list_emulation.pl
#
#  Summary: Demo of creating a linked list in Perl.
#
#  Adapted: Mon 09 Sep 2002 08:12:31 (Bob Heckel --
#                              http://www.tjhsst.edu/~dhyatt/perl/example8)
##############################################################################

# Method #1 using 2D arrays -------------------

sub Print_list {
  $max = $_[0];

  for ( $i=0; $i<$max; $i++ ) {
    print "$i.  $list[$i][0]\t $list[$i][1]\n";
  }
}

# Declare a 2-D Array, which is just an array of 1-D arrays
@list = ( ["vi   ", "Null"], ["emacs", "Null"], ["joe  ", "Null" ]);

$max = $#list + 1;

print "Initial Values\n";
Print_list($max);
print "\n\n";

# Create Some Links
$list[0][1] = 2;  # link vi to joe
$list[2][1] = 1;  # link joe to emacs

print "Made Links\n";
Print_list($max);

$next = 0;
print "\n";

#Step through Linked List
print "Traversing list:\n";
while ( $next !~ "Null" ){
  print "$list[$next][0] \n";
  $next = $list[$next][1];
}
print "\n\n";


# Method #2  Reference Variables, or Pointers -------------------

@links = qw(2 Null 1);

print "Using Pointers\n";

@nodes = qw(finger:Null  whois:Null  who:Null);
for ( $i = 0; $i <= $#nodes; $i++ ) { 
  $ptr = \$nodes[$i];
  @data = split(/:/,$$ptr);
  print "Before:  $ptr  @data ";
  $data[1] = $links[$i];
  print "->  @data \n";
  $$ptr = join ':',@data;
}

print "\n";
print "@nodes";
print "\n";

print "Traversing list:\n";

$next = 0;
while ( $next !~ /Null/ ) {
  @data = split(":",$nodes[$next]);
  print $data[0], "\n";
  $next = $data[1];
}

print "\n\n";


# Method #3 - Using a Hash (probably best) -------------------

print "Using a Hash\n";
%hash = ( "man" =>  "Get UNIX Help:more",
          "cat" => "Display Files:Null",
          "more"=> "Page Through Files:cat"
        );

print "Traversing list:\n";
$next = "man";
while ( $next !~ /Null/ ) { 
  @data = split(/:/, $hash{$next});
  print "$next  $data[0]\n";
  $next = $data[1];
}
print "\n";

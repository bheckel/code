#!/usr/bin/perl -w
##############################################################################
#    Name: hash_of_anonarrs.pl
#
# Summary: Demo using a hash of anonymous arrays to represent a passwd data
#          structure, each hash holding more than one piece of information.
#
#          See also hash_of_arrays.pl
#
# Created: Thu, 04 Jan 2001 12:49:44 (Bob Heckel)
# Modified: Sat 21 Feb 2004 14:18:20 (Bob Heckel)
##############################################################################

while ( <DATA> ) {
  chomp;
  ($name, $pw, $gid, $gecko) = split /:/;
  # Create hash of anonymous arrays, i.e. give a key multiple values instead
  # of the normal single scalar.
  $pwent{$name} = [ $pw, $gid, $gecko ];
}

print "!!!doesn't work:\n";
while ( (my $key, my $value) = each %pwent ){ print "$key=$value\n" };

print "\n!!!works:\n";
###while ( (my $key, my $value) = each %pwent ){ print "$key=@$value\n" };
# Same
while ( (my $key, my $value) = each %pwent ){ print "$key=@{$value}\n" };

# Muck with data.
$pwent{bheckel}[2] = 'CHANGEORAMA';
$pwent{bh1}[0] =~ s/(\w)/\l$1/;
print "\n!!!changed:\n";
while ( (my $key, my $value) = each(%pwent) ){ print "$key=@$value\n" };


__DATA__
bheckel:the:111:geco1
rheckel:spice:222:geco2
robertheckel:must:333:geco3
bh1:FLOW:444:geco4

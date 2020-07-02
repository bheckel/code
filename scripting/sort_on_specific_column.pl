#!/usr/bin/perl -w

open FH, '/cygdrive/c/temp/1' or die "Error: $0: $!";

my $str = do { local $/ = <FH> };  # slurp

# Sort on specific space-separated column:
my $col = 13;

$str = join "\n", 
       map { $_->[0] }
       sort { $a->[1] <=> $b->[1] }
       map { [ $_, (split /,/)[$col] ] }
       split /\n/, $str; 

print $str, "\n";



__END__
# Sort the contents using the last field as the sort key in a Schwartzian tranform.
my $str =<<'EOT';
eir    11   9   2   6   3   1   1   81%   63%   13
oos    10   6   4   3   3   0   4   60%   70%   25
hrh    10   6   4   5   1   2   2   60%   70%   15
spp    10   6   4   3   3   1   3   60%   60%   14

EOT


$str = join "\n", 
       map { $_->[0] }
       sort { $a->[1] <=> $b->[1] }
       map { [ $_, (split)[-1] ] }
       split /\n/, $str; 

print $str, "\n";



__END__
open FH, '/cygdrive/c/temp/1' or die "Error: $0: $!";

my $str = do { local $/ = <FH> };  # slurp

# Sort on specific space-separated column:
my $col = 13;

$str = join "\n", 
       map { $_->[0] }
       sort { $a->[1] <=> $b->[1] }
       map { [ $_, (split)[$col] ] }
       split /\n/, $str; 

print $str, "\n";



__END__
# Sort on specific comma-delimited column:
my $col = 4;

my $str =<<'EOT';
eir,   11,9, 2, 6,3, 1, 1,  81%,  63%,  13
oos,   10,6, 4, 3,3, 0, 4,  60%,  70%,  25
hrh,   10,6, 4, 5,1, 2, 2,  60%,  70%,  15
spp,   10,6, 4, 3,3, 1, 3,  60%,  60%,  14

EOT


$str = join "\n", 
       map { $_->[0] }
       sort { $a->[1] <=> $b->[1] }
       map { [ $_, (split /,/)[$col] ] }
       split /\n/, $str; 

print $str, "\n";




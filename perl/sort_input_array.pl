#!/usr/local/bin/perl

# read the array from standard input one item at a time
print ("Enter the array to sort, one item at a time.\n");
print ("Enter an empty line to quit.\n");
$count = 1;
$inputline = <STDIN>;
chop ($inputline);
while ($inputline ne "") {
        $array[$count-1] = $inputline;
        $count += 1;
        $inputline = <STDIN>;
        chop ($inputline);
}

# now sort the array
$count = 1;
while ($count < @array) {
        $x = 1;
        while ($x < @array) {
                if ($array[$x - 1] gt $array[$x]) {
                        @array[$x-1,$x] = @array[$x,$x-1];
                }
                $x++;
        }
        $count++;
}

# finally, print the sorted array
print ("@array\n");

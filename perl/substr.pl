

# Replace the string returned by the substr() function with "AAA".

$firstVar = "0123BBB789";

substr($firstVar, 4, 3) = "AAA";

print("firstVar  = $firstVar\n");

# This program prints:

# firstVar = 0123AAA789

#!/usr/bin/perl

# zm2 0ZP7880 - 040000736066
# zm2 40000736066  0ZP7880

use warnings;

print "\nrunmacro '/home/chemlms/Scripts/send_result.mcx'\n\n";

$_ = (join ' ', @ARGV) || <>;

print "Input: $_\n\n";
print "STANDARDIZED1: $1-$2-01\n"  if /(\d[zZ][mMpP]\d\d\d\d).*(04\d{10,})/;
print "STANDARDIZED2: $1-$2-01\n"  if /(\d[zZ][mMpP]\d\d\d\d).*(04\d{10,})/;
print "STANDARDIZED3: $1-0$2-01\n" if /(\d[zZ][mMpP]\d\d\d\d).*(4\d{10,})/;
print "STANDARDIZED4: $1-$2-01\n"   if /(\d[zZ][mMpP]\d\d\d\d)\s*-\s*(8\d{10,})/;
print "STANDARDIZED5: $1-$2-01\n"   if /(\d[zZ][mMpP]\d\d\d\d)\s*-\s*(04\d{9,})/;
print "STANDARDIZED6: $1-0$2-01\n"  if /(\d[zZ][mMpP]\d\d\d\d)\s*-\s*(4\d{9,})/;
print "STANDARDIZED7: $1-0$2-01\n"  if /(\d[zZ][mMpP]\d\d\d\d)\s*-\s*(4\d{9,})/;
print "STANDARDIZED8: $2-$1-01\n"  if /\s*(04\d{9,})?-* (\d[zZ][mMpP]\d\d\d\d)\s*/;
print "STANDARDIZED9: $2-0$1-01\n"  if /\s*(4\d{9,})?-* (\d[zZ][mMpP]\d\d\d\d)\s*/;
print "STANDARDIZED10: $2-0$1-01\n"  if /\s*(4\d{9,})?-(\d[zZ][mMpP]\d\d\d\d)\s*/;
print "STANDARDIZED11: $2-0$1-01\n"  if /\s*(4\d{9,})? - (\d[zZ][mMpP]\d\d\d\d)\s*/;
# 40000807550 - 4148428 - 0ZP1401
print "STANDARDIZED12: $3-0$1-01\n"  if /\s*(4\d{9,})? - (\d\d\d\d\d\d\d) - (\d[zZ][mMpP]\d\d\d\d)\s*/;

print "\n\n";

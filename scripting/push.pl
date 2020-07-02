#!/usr/bin/perl -w

# Add to existing environment variables:
# Caution: don't actually run this.  May crash PC.
# Substitute $ENV{'PATH'} for something else.

$ENV{'PATH'} .= ':~bh1/tmp';

push @INC, '~bh1/tmp';

print "ENV PATH is $ENV{'PATH'}";
print "\n";
print "INC is @INC";


# Tip--
# From Return of Program Repair Shop and Red Flags www.perl.com
# Whenever you have code that looks like:
$array[$pos] = SOMETHING;
$pos++;
# You should see if it can be replaced with:
push @array, SOMETHING;
# 97% of the time, it can be replaced. 


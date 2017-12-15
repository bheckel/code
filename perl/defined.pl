#!/usr/bin/perl -w

# Only use defined() on scalars or functions, not on aggregates (arrays and
# hashes)

$destDir = '';

if ( $destDir ) {
  print 'will not print';
}

if ( defined $destDir ) {
  print 'this will';
}


print "\n";
print "\n";
$status = 'suffering';
print defined $status;  # 1, which is a true value
print "\n";
print defined undef;  # empty string; a false value will not print anything
print "\n";


# Avoid errors from an undefined $bbq:
if (defined $bbq and $bbq eq 'brisket') { print 'cookout'; }

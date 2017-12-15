#!/usr/bin/perl -w

# From Programming Perl ch 5.

warn 'here i am';
sub AUTOLOAD {
    my $program = $AUTOLOAD;
    $program =~ s/.*:://;  # trim package name
    system($program, @_);
} 

date();
###whoami('am', 'i');
ls('-l');


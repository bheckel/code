#!/usr/bin/perl -w

opendir MYDIR, "$ENV{HOME}/tmp/03Jul08_1215103192" or die "Error: $0: $!";

@files = sort(grep(/pdf$/, readdir(MYDIR)));

###$num = @files;
###print "$num\n";
# Same
print 'count of files: ';
print $#files+1;

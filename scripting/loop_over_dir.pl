#!/usr/bin/perl -w
##############################################################################
# Program Name: loop_over_dir.pl
#
#      Summary: Iterate over a directory, grabbing all files with .pl
#               extensions.
#
#      Created: Fri Apr 30 1999 10:22:15 (Bob Heckel)
##############################################################################

# Open the current directory.
opendir(MYDIR, ".");
# Read a list of file names using the readdir() function; extract only 
# those that end in pl, and then sort the list.
@files = sort(grep(/pl$/, readdir(MYDIR)));
closedir(MYDIR);

# How many pl found.
$num_of_pls = @files;
print ("$num_of_pls\n");

foreach (@files) {
    # Print the file names from the @files array unless the file is a
    # directory.
    print("$_\n") unless -d;
}

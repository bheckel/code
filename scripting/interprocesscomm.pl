#!/perl/bin/perl -w

# See Learning Perl Ch. 14 for details.
# Using a process as a filehandle:
open(PSHNDL, "ps|");
@processarray = <PSHNDL>;
print "@processarray";
close(PSHNDL);

open(PSHNDL, "ps|");
# Iterate over an open filehandle:
while (<PSHNDL>) {
  unless (/vim/) { # Don't show lines with vim.
    print $_;
  }
}
close(PSHNDL);

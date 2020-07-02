#!/usr/bin/perl -w

# !!!!!!!!!!! EOT must be at col 1 !!!!!!!!!!!

$stuff = <<"EOT";
this is home: $ENV{HOME}
this is shell $ENV{SHELL}
EOT

print $stuff . "\n";


##################
# Using a regex:

%data = <<EOT =~ /(\w+): (.*)/g;
fred: fed flint
barn: bran rub
bety: bett rub
wilm: wim flint
EOT

foreach (sort keys %data) {
  print "$_ is $data{$_}\n";
}

print <<DEADBEET;
This is to inform you that $data{fred} and $data{wilm} are 
insolvent.
DEADBEET


##################
# Write to a filehandle using heredoc:
...

  open(OUT, ">$fqfn") || die "$0: can't open file: $!\n";

  print OUT <<"EOT";
!rts_grget -f $pec $fixid
.$pec
EOT

...


##################
sub Usage {
  print STDERR <<"EOT";
Usage: $0 [-eN -h] FILENAME
       Print every other line of a file to STDOUT (default)
         -e 10  print 10 evenly represented lines to STDOUT
         -h this usage message
EOT
  exit(__LINE__);
}

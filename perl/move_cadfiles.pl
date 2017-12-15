#!/usr/bin/perl -w
##############################################################################
#    Name: move_cadfiles.pl
#
# Summary: Iterate over a directory, find  all files with .cad extensions and
#          move each to /cad
#          Used as part of the GenRad grsuite transition.
#
# Created: Fri, 21 Apr 2000 07:58:49 (Bob Heckel)
##############################################################################

$gr8xprogdir = '/todel/gr8xprog';

# Need to create a cad dir and then move .cad(s) only if release dir has a
# .cad, look thru entire $gr8xprogdir tree for .cads
# TODO inelegant.
@flist = `find $gr8xprogdir`;
@cadsonly = grep(/cad$/, @flist);

# Extract unique elements to avoid multiple attempts to create /cad and move
# .cads
%seen = ();
@uniqcads = ();
foreach $item (@cadsonly) {
  unless ( $seen{$item} ) {
    $seen{$item};
    push(@uniqcads, $item);
  }
}

print "cadfiles located:\n @uniqcads\n";

for ( @uniqcads ) {
  ($pec, $rel, $cadfile) = ( split /\//, $_ )[3,4,5];
  &mkdircadfile($gr8xprogdir, $pec);
  &move_cadfiles($gr8xprogdir, $pec, $rel, $cadfile);
}


sub mkdircadfile {
  # e.g. /todel/gr8xprog
  my($gr8) = shift;
  # e.g. ex54aa
  my($cadless) = @_;

  my($fullpath);

  $fullpath = $gr8 . '/' . $cadless . '/cad';

  # Avoid multiple attempts to create directory.
  unless ( -d $fullpath ) {
    print("Create $fullpath?\n");
    if ( (<STDIN>) !~ /[Nn]/ ) {
      mkdir($fullpath, 755) ? print "Created $fullpath\n\n" :
            print "mkdir failed\n";
    } else {
      print "Not created.\n";
    }
  }
}

sub move_cadfiles {
  my($gr8) = shift;
  my($pecdirectory) = shift;
  my($reldirectory) = shift;
  my($cadtobemoved) = @_;

  chomp($cadtobemoved);

  $beforemoved = $gr8 . '/' . $pecdirectory . '/' . $reldirectory .
                 '/' . $cadtobemoved;
  $aftermoved = $gr8 . '/' . $pecdirectory . '/cad/';

  print "Move this file? $beforemoved\n";

  if ( (<STDIN>) !~ /[Nn]/ ) {
    system("mv $beforemoved $aftermoved") ? 
         print "$beforemoved not moved\n" :
         print "Moved $beforemoved to $aftermoved\n\n";
  } else {
    print "Not created.\n";
  }
}


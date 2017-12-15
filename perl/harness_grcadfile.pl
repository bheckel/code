#!/usr/bin/perl -w
##############################################################################
#     Name: harness_grcadfile.pl
#
#  Summary: Automate debugging.
#
#  Created: Fri 10 Aug 2001 15:13:25 (Bob Heckel)
# Modified: Wed 22 Aug 2001 10:17:21 (Bob Heckel)
##############################################################################

if ( @ARGV && $ARGV[0] =~ /-+h.*/ ) {
  print STDERR "Usage: $0 \n" .
               "       No parameters.  Params to the actual test pgm are \n" .
               "       set up within $0.\n";
  exit(-1);
}


$path = '/home/bheckel/tmp/testing/newone/';
$exe  = 'a.exe';  # pgm currently harnessed, located in same dir as files
$full = $path . $exe;

@passtests = ("$full -c sefile.cad xdir/",
              "$full -C sefile.cad 1>/dev/null",
              "$full -n junkout.nail xdir/",
              "$full -N junkout.nail 1>/dev/null",
             );

@failtests = ("$full 2>/dev/null",           # no switches or params
              "$full -h 2>/dev/null",        # help properly returns false
              "$full -c sefile.BAD xdir/",   # wrong extension
              "$full -c sefile.cad xdir",    # no trailing slash
              "$full -C sefile.BAD",         # wrong extension
              "$full -n junkout.nail xdir",  # no trailing slash
              "$full -n junkout.NAD xdir/",  # wrong extension
              "$full -N junkout.nad",        # wrong extension
             );


print "================Should pass (ie 0)================\n";
foreach ( @passtests, @failtests ) {
  $i_fmt = sprintf("%04d", ++$i);
  $x = system($_);
  $_ =~ s/$full/$exe/;
  print "$i_fmt:\t$_ : ~~~ $x ~~~\n";
  print "\n================Should fail (ie > 0)================\n" 
                                                      if $i == @passtests;
}
print "\n";

system("ls -l xdir/sefile.* xdir/junkout.*");

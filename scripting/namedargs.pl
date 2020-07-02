#!/usr/bin/perl -w
##############################################################################
#    Name: namedargs.pl
#
# Summary: Named parameters to subroutines.
#
# Created: Tue 17 Apr 2001 16:39:32 (Bob Heckel -- based on p 102 OOP Conway)
##############################################################################

%namedargs = (  first => 'number one',
                ###third => 'number three',
               second => 'number two',
             );

callme(%namedargs);


sub callme {
  my %arguments = @_;

  %innersanctum = (   _theone => $arguments{first}  || '??',
                      _thetwo => $arguments{second} || die "need a param\n",
                    _thethree => $arguments{third}  || askme(),  # TODO not working
                  );

  print "Here is $innersanctum{_theone}\n";
  print "Here is $innersanctum{_thetwo}\n";
  print "Here is $innersanctum{_thethree}\n";

  return 1;
}


sub askme {
  print "Must enter a val\n";
  $what = <STDIN>;
  
  print "OK, $what\n";
}

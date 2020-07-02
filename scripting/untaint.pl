#!/usr/bin/perl -w
##############################################################################
#     Name: untaint.pl
#
#  Summary: Taint checking.
#
#  Created: Fri 03 Aug 2001 11:13:25 (Bob Heckel)
# Modified: Mon 24 May 2004 12:19:55 (Bob Heckel -- perlsec)
##############################################################################

delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};   # make %ENV safer

print "ok\n" unless IsTainted('f oo.cd');

sub IsTainted {
  my $data = shift;

  if ( $data =~ /^([-\@\w.]+)$/ ) {
    $data = $1;                     # $data now untainted
  } else {
    die "Bad data in '$data'";      # log this somewhere
  }

  return 0;
}


__END__
# Another approach (testing for insecure characters):
  if ( $value =~ /[&`'\\"|\*?~><\^\(\)\{\}\[\]\$\n\r]/ ) { 
    print_head("die", 500, "Bad Data");
  }

# Or (test for good characters):
if ( $form_data !~ /^[a-zA-Z0-9 \t-@]+$/ ) { 
  print_head("die", 500, "bad data"); 
}

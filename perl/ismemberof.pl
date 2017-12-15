#!/usr/bin/perl -w

@sourcefile_extensions = ('bat', 'foo', 'tpg');
isMemberOf('.tpg', @sourcefile_extensions);

sub isMemberOf {
  my $forcetype = shift;
  my(@sourcefile_extensions) = @_;

  $forcetype = uc($forcetype);
  foreach $ext (@sourcefile_extensions) {
    $ext = '.' . uc($ext);
    print "$forcetype is member" if ($ext eq $forcetype);
    ###return(1) if ($ext eq $forcetype);
  }
}


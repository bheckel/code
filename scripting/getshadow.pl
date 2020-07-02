#!/usr/bin/perl

getshadow('bheckel', 'the9Fisx') ;

sub getshadow {
  my $forminput_name = $_[0];
  my $forminput_pw   = $_[1];

  open(SHADOW, '/etc/shadow') || die "Can't open shadow: $!\n";
  while ( <SHADOW> ) {
    chop;
    #                 ---------future use-------------
    ($userid, $encrypw, $uid, $gid, $gcos, $home, $shell) = split(/:/);
    if ( $userid eq $forminput_name ) {
      cryptcheck($userid, $forminput_pw, $encrypw);
      last;
    }
  }
  close(SHADOW);
}


sub cryptcheck {
  my $userid        = $_[0];
  my $forminput_pw  = $_[1];
  my $encrypw       = $_[2];

  if ( crypt($forminput_pw, $encrypw) ne $encrypw ) {
    print 'fail';
  } else {
    print 'success';
  }
}

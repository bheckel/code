#!/usr/bin/perl -w
##############################################################################
#     Name: unarch
#
#  Summary: Automatically untar code that was frozen via arch and saved to
#           floppy.
#
#           If this changes, make sure arch() in .bashrc changes!
#
#           TODO usage, error checking
#           
#           Superceded by .bashrc's arch()
#
#  Created: Sun, 02 Apr 2000 13:27:01 (Bob Heckel)
# Modified: Thu 20 Sep 2001 09:32:19 (Bob Heckel)
##############################################################################

@tarballs = qw(code.tar bin.tar perllib.tar readme.tar Mail.tar);
@rcfiles  = qw(.bashrc .vimrc .muttrc .slrnrc .lynxrc .lynx.cfg);

foreach $file ( @tarballs ) {
  $rv = undef;
  next unless ( -e "/mnt/floppy/$file.gz" );
  $rv = system("cp /mnt/floppy/$file.gz $ENV{TMP}");

  if ( $rv != -1 ) {
    chdir("/") && system("gunzip $ENV{TMP}/$file.gz") && 
                                            system("tar xvf $ENV{TMP}/$file");
  } else {
    die "Unzip or untar of $file failed somehow. $!\n";
  }
}

print "tarballs done\n";

foreach $rcfile ( @rcfiles ) {
  next unless ( -e "/mnt/floppy/$rcfile" );
  system("cp -v /mnt/floppy/$rcfile $ENV{HOME}") == 0
                                || die "Problem: didn't copy dotfile $rcfile";
}

print "dotfiles done\n";

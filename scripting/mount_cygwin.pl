#!/bin/perl -w

# Date: Fri, 26 Nov 1999 19:53:41 -0800 (PST)
# From: James Ganong <jeg@bigseal.ucsc.edu>
# To: cygwin@sourceware.cygnus.com
# Subject: perl prog that writes a windows .bat file that recreates mounts
# 
# i was inspired by Phil Edwards entry in the todo list 
# at http://sourceware.cygnus.com/cgi-bin/cygwin-todo.cgi?19991124.133151
# "Some kind of 'fstab'" to write a simple perl prog that dumps out the
# current mount configuration into a .bat file that can run from windows
# that will recreate the current mount setup.

@fstab=`mount`;
$mount_path = &which_windows_style_path("mount");
$umount_path = &which_windows_style_path("umount");
print "$umount_path --remove-all-mounts \n";
for (@fstab) {
    next if /^Device/;
    chomp;
    ($device,$dir,$type,$flags) = split;
    $device =~ s/\\/\//g;
    $options = "-f ";  # I force them all, it seems to work better!
    $options .= "-s "  if $type  =~  /system/;
    $options .= "-b "  if $flags  =~  /binmode/;
    $options .= "-x "  if $flags =~  /exec/;
    print "$mount_path $options $device $dir \n";
}

sub which_windows_style_path {
  $command = shift;
  for (split ':', $ENV{PATH}) {
      for ("$_/$command") {
          if (-x $_){
              if ($_ eq "./$command") {
                  $pwd = `pwd`;
                  chomp $pwd;
                  $_ = "$pwd/$command";
              }
              $_ = `cygpath -w $_`;
              chomp;
              return $_;
          }
      }
  }   die "could not find path to $command";
}


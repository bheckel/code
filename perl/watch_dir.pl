#!/c/Perl/bin/perl -w 
##############################################################################
#     Name: watch_dir.pl
#
#  Summary: Monitor directory for changes.  Pop-up a message box if detected.
#
#  Created: Sat Mar 20 1999 21:41:50 (Bob Heckel)
# Modified: Wed 23 Jul 2003 09:59:17 (Bob Heckel)
##############################################################################

use Win32::ChangeNotify;
use Tk;
$|++;

$path = 'c:/tmp/diffdir';
$subtree = 0;
$events = 'LAST_WRITE';

while ( 1 ) {
  $notify = Win32::ChangeNotify->new($path, $subtree, $events);
  $notify->wait or warn "an error has occurred\n";
  $t = scalar(localtime);

  my $mw = MainWindow->new;
  # TODO font color dark
  my $btn = $mw->Button(-text => "$t: File change(s) detected at $path !",
                        -width => 80,
                        -state => 'disabled');
  $btn->pack;
  MainLoop;

  $notify->reset;
  $notify->close;
}

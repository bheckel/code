#!/usr/bin/perl -w
##############################################################################
#     Name: widgets.tk.pl
#
#  Summary: Demo of several widgets.
#
#  Adapted: Wed 12 Nov 2003 13:05:24 (Bob Heckel -- Feb 2003 Linux
#                                     Productivity Magazine)
##############################################################################
use Tk;

my $mw = new MainWindow();
$mw->title ( "Demo of several widgets" );

$mw->Label( -text => "Demo of several delightful Tk widgets" )
  ->pack( -side => "top" );

# Create a variable to hold label when Update button is clicked and it
# changes.  Tk functions are case-sensitive!
my $namelabel = $mw->Label()
  ->pack( -side => "top" );

$mw->Label ( -text => "Your name:" )
  ->pack ( -side => "left" );

my $nent = $mw->Entry( -width => 18 , -justify => 'left' )
  ->pack( -side => 'left' );

my $updbut = $mw->Button( -text => "Update" )
  ->pack( -side => 'bottom' );
$updbut->configure( -command => [ \&entry2label , $nent , $namelabel ] );

my $cancelbut = $mw->Button ( -text => "Cancel" ,
  -command => sub { $mw->destroy() } )
    ->pack ( -side => 'bottom' );

MainLoop();


sub entry2label($$) {
  my ($entry , $label) = @_;

  $label->configure( -text => $entry->get() );
}

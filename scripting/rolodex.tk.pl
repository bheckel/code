#!/usr/local/bin/perl -w
#
# This script was written as an entry in Tom LaStrange's rolodex benchmark. 
# It creates something that has some of the look and feel of a rolodex program,# although it's lifeless and doesn't actually do the rolodex application.
#
# Tcl/Tk -> Perl translation by Stephen O. Lidie.  lusol@Lehigh.EDU  95/01/16
# This needs a good re-write, but no time now (SOL), 96/01/25.

require 5.002;
use English;

use Tk;
use Tk::Dialog;

#------------------------------------------
# Phase 0: create the front end.
#------------------------------------------

$top = MainWindow->new;

$frame = $top->Frame(-relief => 'flat');
$frame->pack(-side => 'top', -fill => 'y', -anchor => 'center');

@names = ('', 'Name:', 'Address:', '', '', 'Home Phone:', 'Work Phone:', 'Fax:');
foreach $i (1..7) {

    # Use symbolic/soft references to create the widget names at object time.
    # Also, we need to keep a mapping of widget names to Perl/Tk references 
    # for the online help to work.

    ($f,$l,$e) = ("frame_${i}", "frame_${i}_l", "frame_${i}_e");
    ${$f} = $frame->Frame();
    ${$f}->pack(-side => 'top', -pady => '2', -anchor => 'e');
    
    ${$l} = ${$f}->Label(-text => $names[$i], -anchor => 'e');
    ${$e} = ${$f}->Entry(-width => '30', -relief => 'sunken');
    ${$e}->pack(-side => 'right');
    ${$l}->pack(-side => 'right');
    $ref_to_name{$e} = ${$e};	# map Entry widget to its Perl/Tk reference
}

$buttons = $top->Frame();
$buttons->pack(-side => 'bottom', -pady => '2', -anchor => 'center');
$buttons_clear = $buttons->Button(-text => 'Clear');
$buttons_add = $buttons->Button(-text => 'Add');
$buttons_search = $buttons->Button(-text => 'Search');
$buttons_delete = $buttons->Button(-text => 'Delete ...');
$buttons_clear->pack(-side => 'left', -padx => '2');
$buttons_add->pack(-side => 'left', -padx => '2');
$buttons_search->pack(-side => 'left', -padx => '2');
$buttons_delete->pack(-side => 'left', -padx => '2');

#------------------------------------------
# Phase 1: Add menus, dialog boxes
#------------------------------------------

$menu = $top->Frame(-relief => 'raised', -borderwidth => '1');
$menu->pack(-before => $frame, -side => 'top', -fill => 'x');

$menu_file = $menu->Menubutton(-text => 'File', -underline => 0);
$ref_to_name{'menu_file'} = $menu_file;
$menu_file->command(-label => 'load ...', -command => \&fileAction,
		    -underline => 0);
$menu_file->command(-label => 'Exit', -command => \&exit, -underline => 0);
$menu_file->pack(-side => 'left');

$menu_help = $menu->Menubutton(-text => 'Help', -underline => '0');
$menu_help->pack(-side => 'right');

# Make all the Dialog objects.

$DELACT = $top->Dialog(
    -title          => 'Confirm Action',
    -text           => 'Are you sure?',
    -bitmap         => 'questhead',
    -default_button => 'Cancel',
    -buttons        => ['OK', 'Cancel'],
);
$FILACT = $top->Dialog(
    -title          => 'File Selection',
    -bitmap         => 'info',
    -text           => 'This is a dummy file selection dialog box, which is used because there isn\'t a good file selection dialog built into Tk yet.',
);
$help = $top->Dialog(-title => 'Rolodex Help',-justify => 'left');

sub deleteAction {
    &clearAction if $DELACT->Show eq 'OK';
}
$buttons_delete->configure(-command => \&deleteAction);

sub fileAction {
    print STDERR "dummy file name\n" if $FILACT->Show eq 'OK';
}

#------------------------------------------
# Phase 3: Print contents of card
#------------------------------------------

sub addAction {
    foreach $i (1..7) {
	($f,$l,$e) = ("frame_${i}", "frame_${i}_l", "frame_${i}_e");
	printf STDERR "%-12s %s\n", $names[$i], ${$e}->get;
    }
}
$buttons_add->configure(-command => \&addAction);

#------------------------------------------
# Phase 4: Miscellaneous other actions
#------------------------------------------

sub clearAction {
    foreach $i (1..7) {
	($f,$l,$e) = ("frame_${i}", "frame_${i}_l", "frame_${i}_e");
	${$e}->delete('0', 'end');
    }
}
$buttons_clear->configure(-command => \&clearAction);

sub fillCard {
    &clearAction;
    my(@text) = ('', 'John Ousterhout', 'CS Division, Department of EECS',
		 'University of California', 'Berkeley, CA 94720',
	'private', '510-642-0865', '510-642-5775');
    foreach $i (1..7) {
	($f,$l,$e) = ("frame_${i}", "frame_${i}_l", "frame_${i}_e");
	${$e}->insert('0', $text[$i]);
    }
}
$buttons_search->configure(-command => sub {&addAction; &fillCard});

#----------------------------------------------------
# Phase 5: Accelerators, mnemonics, command-line info
#----------------------------------------------------

$buttons_clear->configure(-text => 'Clear    Ctrl+C');
$top->bind('<Control-c>' => \&clearAction);
$buttons_add->configure(-text => 'Add    Ctrl+A');
$top->bind('<Control-a>' => \&addAction);
$buttons_search->configure(-text => 'Search    Ctrl+S');
$top->bind('<Control-s>' => sub {&addAction; &fillCard});
$buttons_delete->configure(-text => 'Delete...    Ctrl+D');
$top->bind('<Control-d>' => \&deleteAction);

$menu_file_m = $menu_file->cget(-menu);
$menu_file_m->entryconfigure(1, -accelerator => 'Ctrl+F');
$top->bind('<Control-f>' => \&fileAction);
$menu_file_m->entryconfigure(2, -accelerator => 'Ctrl+Q');
$top->bind('<Control-q>' => sub {exit});

# We do this rather than simply $frame_1_e->focus to eliminate the Perl
# "single use" warning message.

${"frame_1_e"}->focus;

#----------------------------------------------------
# Phase 6: help
#----------------------------------------------------

sub Help {
    my($topic, $x, $y) = @_;
    if ($topic eq '') {return;};
    while (defined $helpCmds{$topic}) {
	$topic = $helpCmds{$topic};
    }
    for $widget (keys %ref_to_name) {
	$topic = $widget if $topic eq $ref_to_name{$widget};
    }
    if (defined $helpTopics{$topic}) {
	$msg  = $helpTopics{$topic};
    } else {
	$msg = 'Sorry, but no help is available for this topic';
    }
    $help->Subwidget('message')->configure(
        -text => "Information on $topic:\n\n$msg");
    $help->Show;
}

$top->bind('<Any-F1>' => sub {
    my $w = shift;
    my $e = $w->XEvent;
    &Help($w->containing($e->X, $e->Y), $e->X, $e->Y);
});
$top->bind('<Any-Help>' => sub {
    my $w = shift;
    my $e = $w->XEvent;
    &Help($w->containing($e->X, $e->Y), $e->X, $e->Y);
});

# Help text and commands follow:

$helpTopics{'menu_file'} = 'This is the "file" menu.  It can be used to invoke some overall operations on the rolodex ' .
  'applications, such as loading a file or exiting.';

$helpTopics{'frame_1_e'} = 'In this field of the rolodex entry you should type the person\'s name';
$helpTopics{'frame_2_e'} = 'In this field of the rolodex entry you should type the first line of the person\'s address';
$helpTopics{'frame_3_e'} = 'In this field of the rolodex entry you should type the second line of the person\'s address';
$helpTopics{'frame_4_e'} = 'In this field of the rolodex entry you should type the third line of the person\'s address';
$helpTopics{'frame_5_e'} = 'In this field of the rolodex entry you should type the person\'s home phone number, or ' .
  '"private" if the person doesn\'t want his or her number publicized';
$helpTopics{'frame_6_e'} = 'In this field of the rolodex entry you should type the person\'s work phone number';
$helpTopics{'frame_7_e'} = 'In this field of the rolodex entry you should type the phone number for the person\'s FAX machine';

$helpCmds{'frame_1_l'} = 'frame_1_e';
$helpCmds{'frame_2_l'} = 'frame_2_e';
$helpCmds{'frame_3_l'} = 'frame_3_e';
$helpCmds{'frame_4_l'} = 'frame_4_e';
$helpCmds{'frame_5_l'} = 'frame_5_e';
$helpCmds{'frame_6_l'} = 'frame_6_e';
$helpCmds{'frame_7_l'} = 'frame_7_e';

$helpTopics{'context'} = 'Unfortunately, this application doesn\'t support context-sensitive help in the usual way, because ' .
	  'when this demo was written Tk didn\'t have a grab mechanism and this is needed for context-sensitive help.  ' .
	  'Instead, you can achieve much the same effect by simply moving the mouse over the window you\'re curious about ' .
	  'and pressing the Help or F1 keys.  You can do this anytime.';
$helpTopics{'help'} = 'This application provides only very crude help.  Besides the entries in this menu, you can get help ' .
	  'on individual windows by moving the mouse cursor over the window and pressing the Help or F1 keys.';
$helpTopics{'window'} = 'This window is a dummy rolodex application created as part of Tom LaStrange\'s toolkit benchmark.  ' .
	  'It doesn\'t really do anything useful except to demonstrate a few features of the Tk toolkit.';
$helpTopics{'keys'} = "The following accelerator keys are defined for this application (in addition to those already " .
	  "available for the entry windows):\n\nCtrl+A:\t\tAdd\nCtrl+C:\t\tClear\nCtrl+D:\t\tDelete\nCtrl+F:\t\tEnter file " .
	  "name\nCtrl+Q:\t\tExit application (quit)\nCtrl+S:\t\tSearch (dummy operation)";
$helpTopics{'version'} = 'This is version 1.0.';

# Entries in "Help" menu

$menu_help->command(-label => 'On Context...', -command => [\&Help, 'context'], -underline => 3);
$menu_help->command(-label => 'On Help...', -command => [\&Help, 'help'], -underline => 3);
$menu_help->command(-label => 'On Window...', -command => [\&Help, 'window'], -underline => 3);
$menu_help->command(-label => 'On Keys...', -command => [\&Help, 'keys'], -underline => 3);
$menu_help->command(-label => 'On Version...', -command => [\&Help, 'version'], -underline => 3);

MainLoop;

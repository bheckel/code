#!/usr/bin/perl -w
##############################################################################
#    Name: tk.pl
#
# Summary: Hideous looking demo of Perl/Tk from http://...
#
# Adapted: Mon 12 Mar 2001 17:32:43 (Bob Heckel)
##############################################################################

use Tk;

my $mainwin = MainWindow->new();
$mainwin->minsize('250', '250');
$mainwin->title('Login');
$mainwin->configure(-background=>'cyan');

my $menubar = $mainwin->Frame(-relief      => 'ridge',
                              -borderwidth => 3,
                              -background  => 'brown',
                             )->pack(-side => 'top',
                                     -fill => 'x'    # Make bar stretch across.
                                    );

########
#
my $filemenubar = $menubar->Menubutton(-text             => 'File',
                                       -background       => 'blue',
                                       -activebackground => 'green',
                                       -foreground       => 'gray',
                                      )->pack(-side => 'left');

$filemenubar->command(-label            => 'Exit',
                      -activebackground => 'yellow',
                      -command          => sub { $mainwin->destroy; }
                     );

$filemenubar->separator();
#
########

########
#
my $helpmenubar = $menubar->Menubutton(-text             => 'Helpme',
                                       -background       => 'blue',
                                       -activebackground => 'pink',
                                       -foreground       => 'white',
                                      )->pack(-side => 'right');

$helpmenubar->command(-label            => 'About',
                      -command          => \&aboutcode
                     );
#
########

# Build invisible body frame that will contain other, smaller, frames:
my $mainfra = $mainwin->Frame(-background => 'cyan')->pack(-side => 'top',
                                                       -fill => 'x',
                                                      );
                       
#######
#
# Place frame (for text labels) inside $mainfra.  Aka column 1.  Each column
# (i.e. set of labels) resides in its own frame.
# Frames are invisible.
my $leftfra1 = $mainfra->Frame(-background => 'gray')->pack(-side => 'left',
                                                            -pady => 9,
                                                            -padx => 8,
                                                           );

# Add text:
my $t1 = $leftfra1->Label(-text       => '',
                          -background => 'cyan',
                      )->pack();

my $t2 = $leftfra1->Label(-text       => 'soylent blue',
                          -background => 'blue',
                      )->pack();

my $t3 = $leftfra1->Label(-text       => 'soylent red',
                          -background => 'red',
                      )->pack();

my $t4 = $leftfra1->Label(-text       => 'soylent green',
                          -background => 'green',
                      )->pack();
#
#######

#######
#
# Place frame (for textboxes) inside $mainfra.  Aka column 2.
my $leftfra2 = $mainfra->Frame(-background => 'cyan')->pack(-side => 'left',
                                                         -pady => 9,
                                                         -padx => 8,
                                                      );

my $box1 = $leftfra2->Label(-text => 'top label')->pack();

my $box2 = $leftfra2->Label(-background  => 'green',
                         -width       => 12,
                         -borderwidth => 2,
                         -relief      => 'sunken',
                        )->pack();

my $box3 = $leftfra2->Label(-background  => 'green',
                         -width       => 12,
                         -borderwidth => 2,
                         -relief      => 'sunken',
                        )->pack();

my $box4 = $leftfra2->Label(-background  => 'green',
                         -width       => 12,
                         -borderwidth => 2,
                         -relief      => 'sunken',
                        )->pack();

#
#######

my $statfra = $mainwin->Frame(-borderwidth  => 3,
                             -relief       => 'groove',
                             -background   => 'purple',
                            )->pack(-side => 'top');

my $stats = $statfra->Label(-width     => 59,
                            -height    => 0,
                            -foreground => 'white',
                            -background => 'purple',
                           )->pack();

$stats->configure(-text => "Status display");


my $mid = $mainwin->Frame( -background   => 'yellow',
                         )->pack(-side => 'top',
                                 -fill => 'y',
                                 -expand => 'y'
                                );


my $go = $mid->Button(-text => 'Select ckbox prior to exiting',
                      -command => sub {exit(0) if $overtimepay},
                     )->pack();


my $ckbtn = $mid->Checkbutton(-variable => \$overtimepay,
                              -text => 'overtime paid at time and a half',
                             )->pack(-side => 'top',
                                     -pady => 2,
                                     -fill => 'x',
                                     -anchor => 'w',
                                    );

MainLoop();   # Stop building widgets, the rest of code is subroutines.

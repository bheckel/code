#!/usr/local/bin/perl -w 
# Simple Tk script to create a button that prints "Hello, world".  Click on 
# the button to terminate the program.
# 
# The first line below imports the Tk objects into the application, the second
# line creates the main window, the third through sixth lines create the button
# and defines the code to execute when the button is pressed, the seventh line
# asks the packer to shrink-wrap the application's main window around the
# button, and the eight line starts the event loop.
use Tk;


# CALLBACK SYNTAX EXAMPLES
# Anonymous:
# 	sub {print "\007";}
#
# Reference:
# 	\&soundbell
#
# String syntax:
# 	[ 'soundbell' ]

$x = 1;
$MW = MainWindow->new;
$hello = $MW->Button(
    -text    => 'Hello, world', 
    -command => sub {print STDOUT "Hello, world\n"; exit;},
);
$hello->pack;

if ( $x == 1 ) {
  MainLoop;
}


__END__
# Alternate "Hello World" with a Label and explicit event binding. 
my $mw = MainWindow->new; 

my $label = $mw->Label(-text => 'Hi World'); 
$label->pack; 
$label->bind('<Button-1>' => sub {$mw->destroy}); 

MainLoop; 

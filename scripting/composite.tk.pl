#!/usr/local/bin/perl -w


use English;
use Tk;
require Tk::demos::LabEnLabRad;
use strict;

my $MW = MainWindow->new;

# Create and pack the expandable LabeledEntryLabeledRadiobutton widget.  Then
# globally configure the advertised Frame, Label and Radiobutton widgets.
# Lastly, specifically configure the radiobutton widget labeled 'RL3', a tiny
# widget inside the advertised composite LabeledRadiobutton widget, the
# entry widget in the advertised composite LabeledEntry widget, and then 
# create some key bindings.

my $entry_var = 'Frogs lacking lipophores are blue.';
my $radio_var = '';
my $cw = $MW->LabeledEntryLabeledRadiobutton(
    'Name'          => 'frog',
    -entry_label    => 'Entry Label',
    -entry_variable => \$entry_var,
    -radio_label    => 'Radio Label',
    -radio_variable => \$radio_var,
    -radiobuttons   => [qw(RL1 RL2 RL3 RL4 RL5)],
);
$cw->pack(-expand => 1, -fill => 'both');

print "Check out composite widget hierarchy ...\n";
$cw->Walk(sub {print "  subwidget=", shift->PathName, "\n";});

$cw->Walk(
    sub {
        my($w, $class) = @_;
        $w->configure(-relief => 'ridge', -bd => 5) if $class eq $w->class;
    }, 'Frame',
);    
$cw->Walk(
    sub {
        my($w, $class) = @_;
        $w->configure(-relief => 'flat', -bg => 'azure') if $class eq $w->class;
    }, 'Label',
);
$cw->Walk(
    sub {
        my($w, $class) = @_;
        $w->configure(-selectcolor => 'red', -indicatoron => 0, -bg => 'green')
            if $class eq $w->class;
    }, 'Radiobutton',
);

my $r = $cw->Subwidget('labeled_radiobutton')->Subwidget('RL3');
$r->configure(-bg => 'pink', -command =>
    sub {print "radiobutton 'RL3' selected!\n";}
);

$cw->bind('<Return>' => \&process_return );

$cw->Subwidget('labeled_entry')->configure(-bg => 'orange');

# Create and pack a button that demonstrates how to reconfigure the entire
# composite widget by invoking the `configure' method on the composite
# widget rather than on specific subwidgets, or classes of widgets.

my $b;
$b = $MW->Button(-text => 'Reconfigure subwidgets', -command =>
    sub {
        $cw->configure(
            -background         => 'cyan',
            -foreground         => 'blue',
            -borderwidth        => 0,
            -relief             => 'ridge',
            -highlightthickness => 0,
            -indicatoron        => 1
        );
        $b->packForget;
    }
);
$b->pack(-side => 'top', -expand => 1, -fill => 'both');

# Create and pack the Quit button.

my $q = $MW->Button(-text => 'Quit', -command => sub{exit});
$q->pack(-side => 'top', -expand => 1, -fill => 'both');

MainLoop;

sub process_return {

    my($objref) = @_;

    print "In entry callback, objref=$objref, \$entry_var=\'$entry_var\'.\n";

} # end process_return

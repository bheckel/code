# Sample tk program for Perl2Exe

use Tk;


my $main = new MainWindow;
$main->Label(-text => 'Print file')->pack;
my $font = $main->Entry(-width => 10);
$font->pack;
my $filename = $main->Entry(-width => 10);
$filename->pack;
$main->Button(-text => 'Fax',
              -command => sub{do_fax($filename, $font)}
              )->pack;
$main->Button(-text => 'Print', 
              -command => sub{do_print($filename, $font)}
              )->pack;
MainLoop;

sub do_fax {
    my ($file, $font) = @_;
    my $file_val = $file->get;
    my $font_val = $font->get;
    print "Now faxing $file_val in $font_val\n";
}

sub do_print {
    my ($file, $font) = @_;
    $file = get $file;
    $font = get $font;
    print "Sending file $file to printer in $font\n";
}

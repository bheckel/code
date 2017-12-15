#! /usr/bin/perl -w

require 5.003;
use strict;
use Tk;

my $mw = new MainWindow();
$mw->title ( "Revenue by Year and Quarter" ) ;

$mw->Label ( -text => "Revenue by Year and Quarter ( Millions ) " ) 
        ->pack ( -side => "top" , -anchor => 'center' ) ;

my $fgrid = $mw->Frame()->pack ( -side => 'top' ) ;

my @year_col = (
        $fgrid->Label ( -text => 'Year' ),
        $fgrid->Label ( -text => '2000' ),
        $fgrid->Label ( -text => '2001' ),
        $fgrid->Label ( -text => '2002' ),
        $fgrid->Label ( -text => '2003' ),
);

my @ceo_col = (
        $fgrid->Label ( -text => 'CEO' ),
        $fgrid->Entry ( -width => 14 , -justify => 'left' ),
        $fgrid->Entry ( -width => 14 , -justify => 'left' ),
        $fgrid->Entry ( -width => 14 , -justify => 'left' ),
        $fgrid->Entry ( -width => 14 , -justify => 'left' ),
);
my @fq1_col = (
        $fgrid->Label ( -text => 'Q1' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
);

my @fq2_col = (
        $fgrid->Label ( -text => 'Q2' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
);

my @fq3_col = (
        $fgrid->Label ( -text => 'Q3' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
);

my @fq4_col = (
        $fgrid->Label ( -text => 'Q4' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
);

my @total_col = (
        $fgrid->Label ( -text => 'Total' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
        $fgrid->Entry ( -width => 6 , -justify => 'right' ),
);

my @columns = (
        \@year_col,
        \@ceo_col,
        \@fq1_col,
        \@fq2_col,
        \@fq3_col,
        \@fq4_col,
        \@total_col,
);

my $col = 0;
foreach my $column (@columns)
{
        my $row = 0;

        foreach my $entry (@$column)
        {
                $entry->grid(-column => $col, -row => $row, -padx => 4);
                $row++;
        }
        $col++;
}

MainLoop();

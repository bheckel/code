package Checklist;
##############################################################################
#    Name: Checklist.pm
#
# Summary: Objectify an ini-style (e.g. NPI Checklist) file for easy
#          manipulation.
#
#  --------------------------------------------------------------------
#   Desired (abbreviated) output. 
# OLD
#     %hah = ( prebuild => [
#                            { a_date => 9876 ,  group => 'prodeng' },
#                            { a_date => 9877 ,  group => 'qrodeng' },
#                          ],
#  
#                 build => [
#                            { a_date => 5432 ,  group => 'ooeng'},
#                            { a_date => 5433 ,  group => 'poeng'},
#                            { a_date => 9999 ,  group => 'found'},
#                          ],
#            );
#  
# NEW
#     %hhh = ( prebuild => {
#                            { a_date => 9876 ,  group => 'prodeng' } => 1,
#                            { a_date => 9877 ,  group => 'qrodeng' } => 1,
#                          },
#  
#                 build => {
#                            { a_date => 5432 ,  group => 'ooeng'} => 1,
#                            { a_date => 5433 ,  group => 'poeng'} => 2,
#                            { a_date => 9999 ,  group => 'found'} => 2,
#                          },
#            );
#  --------------------------------------------------------------------
#
# Created: Thu 01 Mar 2001 13:10:30 (Bob Heckel)
# Modified: Fri 09 Mar 2001 13:43:10 (Bob Heckel)
##############################################################################

require ConfLib;


sub new {
  my $class = shift;
  # Allocate memory for object.  $self = HASH(0x987654)
  my $self  = {};

  # Associate reference (i.e. $self) with this package (i.e. $class).
  bless($self, $class);

  # Object now exists.  $self = Checklist=HASH(0x987654)

  # Initialize data members (aka attributes, properties).
  $self->{cellvals}  = {};
  $self->{hdrvals}   = {};
  # E.g. SOL5678_89.cl
  $self->{inputfile} = undef;
  $self->{conflob}   = new ConfLib; 

  # Return reference.
  return $self;
}

# Public object methods:

sub load {
  my $self = shift;
  my $fn   = shift;

  $self->{inputfile} = $fn;

  my $rc = $self->{conflob}->load($fn); 

  foreach $section ( $self->{conflob}->sectionList() ) {
    # Assumes sections will look like this [postbuild:2]
    if ( $section =~ /([a-zA-Z]+):(\d+)/ ) {
      #                                    from ConfLib namespace
      $self->{cellvals}{$1}{$2} = $self->{conflob}{'values'}{$section};
    } elsif ( $section eq 'header' ) {
      $self->{hdrvals}{header} = $self->{conflob}{'values'}{$section}; 
    }
  }

  return $rc;
}


#########
#
sub getHdrCellNames {
  my $self = shift;

  my @rows = ();
  foreach my $row ( sort {$a<=>$b} keys %{ $self->{hdrvals}{header} } ) {
    push(@rows, $row);
  }

  return @rows;
}


sub getHdrCellVal {
  my $self = shift;
  my $cellname = shift;

  my $cellval =  $self->{hdrvals}{header}{$cellname};

  return $cellval;
}
#
#########


sub getTblNames {
  my $self = shift;

  my $tbl;
  my @tbls = ();

  foreach $tbl ( sort keys %{ $self->{cellvals} } ) {
    push(@tbls, $tbl);
  }

  return @tbls;
}


sub getRows {
  my $self = shift;
  my $tablename = shift;
  
  my @rows = ();
  ###foreach $rownum ( @{ $self->{cellvals}{$tablename} } ) {
  foreach my $row ( sort {$a<=>$b} keys %{ $self->{cellvals}{$tablename} } ) {
    push(@rows, $row);
  }

  return @rows;
}


sub getCellNames {
  my $self = shift;
  my $tablename = shift;
  my $row = shift;

  my @cells = ();

  foreach my $cell ( sort keys %{ $self->{cellvals}{$tablename}{$row} } ) {
    push(@cells, $cell);
  }

  return @cells;
}


sub getCellVal {
  my $self = shift;
  my $tablename = shift;
  my $row = shift;
  my $cellname = shift;

  my $cellval =  $self->{cellvals}{$tablename}{$row}{$cellname};

  return $cellval;
}


sub setCellVal {
  my $self = shift;
  my $tablename = shift;
  my $row = shift;
  my $cellname = shift;
  my $x = shift;

  my $previous = $self->{cellvals}{$tablename}{$row}{$cellname};

  $self->{cellvals}{$tablename}{$row}{$cellname} = $x;

  return $previous;
}


sub removeCellName {
  my $self = shift;
  my $tablename = shift;
  my $row = shift;
  my $cellname = shift;

  # The way ConfLib expects a [section].
  my $translate = join(':', $tablename, $row);
  ###delete $self->{cellvals}{$tablename}{$row}{$cellname};
  $self->{conflob}->removeKey($translate, $cellname);

  return 1;
}


sub swapRow {
  my $self = shift;
  my $tablename = shift;
  my $row1 = shift;
  my $row2 = shift;

  # The way ConfLib expects a [section].
  my $translate1 = join(':', $tablename, $row1);
  my $translate2 = join(':', $tablename, $row2);

  # TODO WORKS BUT DOESNT ALLOW SAVE
  ###$tmpref = $self->{cellvals}{$tablename}{$row1};
  ###$self->{cellvals}{$tablename}{$row1} = $self->{cellvals}{$tablename}{$row2};
  ###$self->{cellvals}{$tablename}{$row2} = $tmpref;

  my $ref1 = $self->{conflob}{'values'}{$translate1};
  my $ref2 = $self->{conflob}{'values'}{$translate2};

  my $tmpref = $ref1;
  $ref1 = $ref2;
  $ref2 = $tmpref;

  $self->{conflob}{'values'}{$translate1} = $ref1;
  $self->{conflob}{'values'}{$translate2} = $ref2;


  ###$self->{conflob}{'values'}{$translate1} = 
                                    ###$self->{conflob}{'values'}{$translate2};
  ###$self->{conflob}{'values'}{$translate2} = $tmpref;

  return 1;
}


sub insertRow {
  my $self = shift;
  my $tablename = shift;
  my $row1 = shift;
  my $row2 = shift;

###  my %tmp = $self->{conflob}->section{$translate1};
###
###  $self->{conflob}->removeSection($translate1);
###
###  $self->{cellvals}{$tablename}{$rowname2};
###                              $self->{cellvals}{$tablename}{$row}{$cellname2};
###
  ###$self->{cellvals}{$tablename}{$row}{$cellname2} = $tmp;

  return 1;
}


sub saveobj {
  my $self = shift;

  $self->{conflob}->save("junk.txt");

  return 1;
}


1;

__END__
#!/usr/bin/perl
##############################################################################
#    Name:
#
# Summary: 
#
# Created: Thu 01 Mar 2001 13:10:30 (Bob Heckel)
##############################################################################

use Checklist;

$cklobj = new Checklist;

$cklobj->load('SOL5678_89.cl') || die "didn't load";

@hdrs = $cklobj->getHdrCellNames();
###print "hdrs: @hdrs\n";

$hdrsval = $cklobj->getHdrCellVal('EC');
###print "hdrsval: $hdrsval\n";

@tblnames = $cklobj->getTblNames();
###print "table names: @tblnames\n";

my @rows = $cklobj->getRows('prebuild');
###print "rows: @rows\n";

my @cells = $cklobj->getCellNames('prebuild', '1');
###print "cells: @cells\n";

my $cellval = $cklobj->getCellVal('prebuild', '1', 'a_date');
###print "cellval: $cellval\n";

###$cklobj->setCellVal('prebuild', '1', 'a_date', 'voila!');
###my $cellval = $cklobj->getCellVal('prebuild', '1', 'a_date');
###print "cellval: $cellval\n";

###$cklobj->removeCellName('prebuild', '2', 'INV');

###$cklobj->swapRow('prebuild', '2', 'a_date', 'another');
$cklobj->swapRow('prebuild', '1', '2');
$cklobj->saveobj();

# Display entire checklist.
foreach my $tblname ( $cklobj->getTblNames() ) {
  foreach my $row ( $cklobj->getRows($tblname) ) {
    foreach $cellname ( $cklobj->getCellNames($tblname, $row) ) {
      $cellvalue = $cklobj->getCellVal($tblname, $row, $cellname );
      print "$tblname     \t$row\t$cellname = $cellvalue\n";
    }
  }
}


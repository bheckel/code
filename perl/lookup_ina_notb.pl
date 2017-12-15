#!/usr/bin/perl -w
##############################################################################
#     Name: lookup_ina_notb.pl
#
#  Summary: Find elements in file A but not in file B.
#
#  Adapted: Fri 13 Feb 2004 15:13:50 (Bob Heckel --
#                            file:///C:/bookshelf_perl/cookbook/ch04_08.htm)
##############################################################################
use strict;

my (@a, @b, @aonly, %seen, $item);

########## Start load arrays with data ####################
open FHA, 'junksms' or die "Error: $0: $!";

open FHB, 'junktbe' or die "Error: $0: $!";

# 2 BF19.AKX02013.NATSCP  FILES 03MAR2003 02MAR2004
# 3 BF19.AKX0204.MEDMER FILEM 28MAR2003 27MAR2004
while ( <FHA> ) {
  # DEBUG toggle
  ###last if $. > 10;
  next if /^obs/i;
  my ($obs, $fn) = split;
  push @a, "$fn\n";
}

# 0NONVSAM ------- BF19.TXX9510.NATMER1
# 0NONVSAM ------- BF19.UTX9512.NATMER1
while ( <FHB> ) {
  next if /^\*/;
  my $fn = (split)[2];
  push @b, "$fn\n";
}
########## End load arrays with data #####################


%seen = ();    # lookup table to test membership of B
@aonly = ();   # answer

# Record each element of B.
foreach $item ( @b ) {
  $seen{$item} = 1;
}

# Build lookup table.
foreach $item ( @a ) {
  push @aonly, $item unless $seen{$item};
  $seen{$item} = 1;   # no dups in A
}

print "@aonly\n";

__END__
Samples:

Obs	DSN	Management Class	Last Reference Date	Expiration Date
1	BF19.AKX0110.MEDMER1	FILES	12MAR2003	11MAR2004
2	BF19.AKX02013.NATSCP	FILES	03MAR2003	02MAR2004
3	BF19.AKX0204.MEDMER	FILEM	28MAR2003	27MAR2004
4	BF19.AKX0205.MICMER	FILEM	04MAR2003	03MAR2004
5	BF19.AKX0206.MICCOP	FILEM	03MAR2003	02MAR2004
7	BF19.CAX0206.FETMER	FILEM	28MAR2003	27MAR2004
6	BF19.AKX0206.MICMER	FILEM	13MAR2003	12MAR2004
7	BF19.NJX0207.MICMER	FILEM	28MAR2003	27MAR2004
8	BF19.AKX03002.NATSCP	FILES	06MAR2003	05MAR2004
7	BF19.NJX0207.MICMER	FILEM	28MAR2003	27MAR2004
9	BF19.AK01.AK03002S.NATCOP.R306P002	FILEM	11MAR2003	10MAR2004

*ENTER BY EVENT/DESCEND ORDER PLEASE COPY INTO BACKUP AFTER ANY UPDATE;
*1997 MICAR TOT RECS = 18*1998 MICAR TOT RECS = 53;FETAL 2002*1997;
*MEDMER 2002*1997 MICMER 2002*1997 MORMER 2002*1994 NATMER 2002*1994;
0NONVSAM ------- BF19.AKX0208.FETMER
0NONVSAM ------- BF19.ALX0209.FETMER
0NONVSAM ------- BF19.ARX0205.FETMER
0NONVSAM ------- BF19.ASX0201.FETMER
0NONVSAM ------- BF19.AZX0203.FETMER
0NONVSAM ------- BF19.CAX0206.FETMER
0NONVSAM ------- BF19.COX0203.FETMER

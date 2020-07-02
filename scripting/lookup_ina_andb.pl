#!/usr/bin/perl -w
##############################################################################
#     Name: lookup_ina_andb.pl
#
#  Summary: Find records in common between 2 files.  In the original case,
#           we're making sure that there are *no* common records.
#
#           Somewhat like an SQL inner join.
#
#  Adapted: Fri 13 Feb 2004 15:13:50 (Bob Heckel --
#                            file:///C:/bookshelf_perl/cookbook/ch04_08.htm)
##############################################################################
use strict;

my (@a, @b, @aandb, %seen, $item);

########## START load arrays with data ####################
open FHA, 'smsrpt_24.txt' or die "Error: $0: $!";
###open FHA, 'junksms' or die "Error: $0: $!";

open FHB, 'TBE2.FINAL.BF19.DATASET' or die "Error: $0: $!";
###open FHB, 'junktbe' or die "Error: $0: $!";

while ( <FHA> ) {
  # DEBUG toggle
  ###last if $. > 10;
  next if /^obs/i;
  my ($obs, $fn) = split;
  $fn = uc $fn;
  push @a, "$fn\n";
}

while ( <FHB> ) {
  next if /^\*/;
  my $fn = (split)[2];
  $fn = uc $fn;
  push @b, "$fn\n";
}
########## END load arrays with data #####################


%seen = ();    # lookup table to test membership of B
@aandb = ();   # answer

# Record each element of B.
foreach $item ( @b ) {
  $seen{$item} = 1;
}

# Build lookup table.
foreach $item ( @a ) {
  push @aandb, $item if $seen{$item};
  ###$seen{$item} = 1;   # no dups in A (often doesn't matter)
}

# May be dups in B but that is usually ok.
print "@aandb\n";

__END__
Samples:

A:

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

B: 

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

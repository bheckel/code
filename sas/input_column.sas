 /*----------------------------------------------------------------------------
  *      Name: input_column.sas
  *
  *   Summary: Demo of column input for data that has only STANDARD data that 
  *            is always at the same column location.
  *
  *           Standard numerics:
  *           -15, 15.4, +.05, 1.54E3, -1.54E-3
  *
  *            Leading and trailing spaces are ignored.  No need for delimiters.
  *
  *            Good for reading data with embedded blanks.  Parts of fields can
  *            be re-read.
  *
  *            Limitation:
  *             Incoming data must be in standard SAS num or SAS char format.
  *
  *   Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 2.4)
  * Modified: Thu 01 Jul 2010 08:27:21 (Bob Heckel)
 *----------------------------------------------------------------------------
 */

data sales;
  ***infile 'c:\MyRawData\Onions.dat';
  infile cards firstobs=2 obs=4;  /* strangely Columbia thru Gilroy */
  input VisitingTeam $ 1-20  ConcessionSales 21-24  BleacherSales 25-28
        OurHits 29-31  TheirHits 32-34  OurRuns 35-37  TheirRuns 38-40
        _numofcolumnsreadsetslength $ 45
        ;
  list;
  /* Data errors like ConcessionSales' x10 are merely acknowledged and set to '.' by SAS */
  cards;
----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0 
Columbia Peaches      35  67  1 10  22E5    a
 Plains Peanuts      x10      2  5  0  2    bTHISISTRUNCATED!
Gilroy Garlics        151035 12 11  7       c
Sacramento Tomatoes  124  85 15  4  9  1    d
  ;
run;
title '"NOTE: Invalid data for ConcessionSales in line 36 21-24." is ok in this demo';
proc print; run;
proc contents; run;

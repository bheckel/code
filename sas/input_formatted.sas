 /*---------------------------------------------------------------------------
  *     Name: input_formatted.sas
  *
  *  Summary: Demo of formatted input for data that has variables that are
  *           standard OR NON-STANDARD SAS data IN FIXED FIELDS.
  *
  *           See simpler, but more limited, input_column.sas for reading in
  *           pure standard data.
  *
  *           Standard numerics:
  *           -15, 15.4, +.05, 1.54E3, -1.54E-3
  *
  *           See sql_sasformat.sas for an SQL approach.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 2.5)
  * Modified: Thu 01 Jul 2010 08:59:26 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data tmp;
  /* Using pointer controls and informats: */
  /* 3.1 instead of 3. assumes the data needs a decimal place added when stored */
  input Name $16.  Fraction 3.1  +1  Type $1.  +1  Dt MMDDYY10.
        (Score1-Score4) (4.1)  /* need 4.1 (or really just 4.) instead of 3.1 or have to +1 to move the cursor */
        ;
  list;
  cards;
Alicia Grossman  13 c 10-28-1999 7.8 6.5 7.2 8.0 7.9
Lori Newcombe    60 D 10-30-1999 6.7 5.6 4.9 5.2 6.1
Jose Martinez     7 d 10-31-1999 8.9 9.510.0 9.7 9.0
Brian Williams   11 C 10-29-1999 7.8 8.4 8.5 7.9 8.0
  ;
run;
proc print; run;



title 'Eliminate leading spaces';
data sample;
  infile cards;  /* not mandatory if using 'cards' device */
  /* Take away the '.' and you'll be referring to column position (not
   * usually what you want). 
   */
  input @1 state $14.  @1 dup $12.  @16 abb $2.;
  cards;
 Pennsylvania  PA
Minnesota      MN
Vermont        VT
South Dakota   SD
  ;
run;
proc print; run;

title 'Maintain leading spaces';
data sample;
  input @1 state $CHAR14.  @1 dup $CHAR12.  @16 abb $CHAR2.;
   cards;
 Pennsylvania  PA
Minnesota      MN
North Carolina NC
North Dakota   ND
North Carolina NC
  ;
run;
proc print; run;


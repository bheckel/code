options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: format_informat.sas (not proc format)
  *
  *  Summary: Demo of the difference between format and informat statements.
  *
  *           A SAS informat is an instruction that converts the values from a
  *           character string representation into the internal numerical
  *           value of a SAS variable. Date informats convert dates from
  *           ordinary notations used to enter them to SAS date values;
  *           datetime informats convert date and time from ordinary notation
  *           to SAS datetime values.
  *
  *           So you could say "the informat converts and the format prints"
  *
  *  Created: Mon 05 May 2003 11:20:19 (Bob Heckel)
  * Modified: Mon 09 Jun 2003 15:35:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

title 'INFORMAT -- Read calendar dates as SAS date:';
data informatsample;
  infile cards;
  /* For reading raw data: */
  informat dt DATE9.;
  input dt;
  /* For presentation.  Otherwise get SAS numeric date (e.g. 14020). */
  format dt MONYY.;
  cards;
21MAY1998
07JUL2000
  ;
run;
proc print; run;

title 'FORMAT -- Write SAS date value in recognizable form:';
data formatsample;
  /* dummy vars are intentionally uninitialized to prove they are
   * automatically added (i.e. they implicitly create new variables) to the
   * ds. 
   */
  format dt DATE9.  dummyuninit $char8.;
  length anotherdummyuninit $9;
  attrib yetanotherdummyuninit format=$char7. label='implicit, also unused';

  dt=14686;
run;
proc print; run;
proc contents;run;

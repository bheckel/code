options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: read_commadelimCSV.sas
  *
  *  Summary: Read in a comma delimited file CSV.
  *
  *           Copy header from Excel, use Vim to build an input statement:
  *             input Product :$40.
  *                   Batch :$40.
  *                   Material :$40.
  *                   Date_of_Manufacture :DATE9.
  *                   Process_order :$40. ...
  *
  *           See build_material_mapping_ds.sas
  *
  *  Created: Mon 17 Mar 2003 13:33:37 (Bob Heckel)
  * Modified: Thu 19 Jul 2012 10:44:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.commadelimited;
  /* DLM=, is optional (defaults to comma)        */
  /*         consecutive delim ok   skip hdr line */
  /*                   ___          __________    */
  infile cards DLM=',' DSD MISSOVER FIRSTOBS=2;
  /* Next line not needed if use '$' on the input line and str is <= 8 chars */
  ***informat state $2.  mo $2.  type $4.  ship $2.  extension $2.;
  /* Better, don't need an INFORMAT and an INPUT line */
  /* Numbers indicate the max widths (beyond that is ignored) */
  input state :$2.  mo :$2.  type :$80.  ship :$2.  extension :$200.  num;
  ***input state $  mo $  type $  ship $  extension $  num;
  list;
  cards;
State,Month, Type, Ship, Ext
nd,03,mor mer,01,,99
nm,03,mor mer,01,a,88,
nm,03,nat mer,01,a,77
  ;
run;
proc print; run;

options nosource;
 /*---------------------------------------------------------------------------
  *     Name: input_list.sas
  *
  *  Summary: Demo of simple and modified list input for data that is
  *           separated by at least one space (aka free-formatted input).
  *           No need to specify column locations when using free formatted
  *           data.
  *
  *           Limitations:
  *             Must read *all* data (no skipping variables).
  *
  *             Character data must be simple (no embedded spaces and no
  *             values greater than 8 chars (unless use LENGTH).
  *
  *             Dates will be a problem.
  *
  *  Adapted: Wed 22 Jan 2003 14:03:53 (Bob Heckel --
  *                                    C:\bookshelf_sas\lrcon\z0695211.htm)
  * Modified: Fri 18 Jun 2010 15:13:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* List input scans for space(s) delimiter by default. */
data spacedelimited;
  /* Default is length of 8 for chars so we will be truncating here */
  input idno  name $  color $  startwght  endwght;
  list;
  cards;
023 SASSystemV8  red    189 -165
049 PerlProg yellow 190   166
023 SAS red    +191 167
  ;
run;
proc print data=_LAST_(obs=max); run;


data simple_list;
  /* DELIMITER doesn't matter in this e.g. b/c a single space is the default
   * delimiter for list input. 
   */
  ***infile cards DELIMITER=' ';
  /* Override the default char width of 8 */
  length name $ 12;
  input name $  score1  score2;
  /* Data runs together on a line but must be delimited by one or more spaces.
   * Blanks must be represented a value (i.e. a period). 
   */
  list;
  datalines;
Devils  1132 1187
Hurricanes . 1102
Capitals 1016 1103
  ;
run;

 /* Note: for list style input, the pointer stops at position 8, NOT 7 (as it
  * would for the other styles) !!

----+----1----+----2
Devils  1132 1187

  */

data simple_delimited;
  /* Keep the quotes. */
  infile cards DELIMITER=',';
  /* Drop the quotes and embedded commas, double commas indicate missing.
   * When using DSD, the DELIMITER == ',' by default.
   */
  ***infile cards DELIMITER=',' DSD;
  length name $ 12;
  input name $  score1  score2;
  list;
  /* Must be delimited by one or more spaces. */
  /* Blanks must be represented a value (i.e. a period). */
  datalines;
Devils, 1132,1187
"Hurr canes",.,1102
Capitals,1016,1103
  ;
run;


data modified_list1;
  /* Don't need length statment if using a colon modified list input b/c the
   * colon allows informats on the input statement line. 
   */
  ***length name $ 12;
  /* The date9. informat is allowed since the : colon preceeded it. */
  input dt :date9.  score1  score2;
  datalines;
01JAN60  1132 1187
01JAN62 . 1102
01JAN65 1016 1103
  ;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max);run;


data modified_list2;
  input name &$12.  score1  score2;
  /* Ampersand format modifier accepts embedded space so data must be
   * delimited by TWO or more spaces. 
   */
  datalines;
Devils  1132 1187
Hurry Canes  .  1102
Capitals  1016 1103
  ;
run;


 /* Tilde modifier seems fairly useless (or just more obscure), see  data
  * simple_delimited above. 
  */
data modified_list3;
  ***infile cards DELIMITER=',' DSD;
  /* Same */
  infile cards DSD;
  /* Same (when using tilde). */
  ***infile cards DELIMITER=',';
  /* The tilde format modifier keeps the quotes. */
  input name ~$12.  score1  score2;
  datalines;
Devils,1132,1187
"Hurry, Cane",, 1102
Capitals,1016,1103
  ;
run;

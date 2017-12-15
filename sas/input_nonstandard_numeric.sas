options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_nonstandard_numeric.sas
  *
  *  Summary: Demo of reading nonstandard numeric data into SAS.
  *
  *           Standard numerics:
  *           -15, 15.4, +.05, 1.54E3, -1.54E-3
  *
  *  Created: Fri 18 Jun 2010 10:35:05 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Commas, parentheses, percent signs in the data are 'non-standard'.  The
  * COMMAw.d informat removes them before storing in a dataset.
  */
data t;
  infile cards;
  list;
  /* Don't need a '+1' between n1/n2 since it's "list input" but do for the
   * other, nonstandard, because it's "formatted input"
   */
  input n1  n2 COMMA7.  +1  n3 COMMA12.2  +1  n4 COMMA12.2  +1  n5 COMMA3.  +1  n6 COMMA9.;  /* TODO why need the .d for (123,456.01) but not 12,345.67? */
  cards;
123.49 123,456 (123,456.01) (823,456.01) 50% 12,345.67
+123.49 123,456 (123,456.01) (823,456.01) 50% 12,345.67
923.48 923,456 (923,456.02) (923,456.02) 95% 12,345.68
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;

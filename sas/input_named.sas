options nosource;
 /*---------------------------------------------------------------------------
  *     Name: input_named.sas
  *
  *  Summary: Demo of using named input.
  *
  *           No need to roll your own .INI file reader if use this.
  *
  *  Created: Thu 06 Mar 2003 12:37:37 (Bob Heckel)
  * Modified: Wed 20 Nov 2013 10:22:47 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data t;
  input nm= $  score1=  score2=;

  /* DEBUG - display each line as it's read-in */
  put '!!!' _INFILE_;

  if index(_INFILE_, 'INI') then delete;

  datalines;
INI data starts below
nm=foo score1=1134 score2=1189
name=bar score1=1134 score2=1189
nm=baz score1=9999 score2=8888
  ;
run;
proc print; run;
